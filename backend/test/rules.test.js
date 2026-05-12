const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const { readFileSync } = require("fs");
const { describe, it, before, after, beforeEach } = require("mocha");

let testEnv;

before(async () => {
  // Initialize testing environment
  testEnv = await initializeTestEnvironment({
    projectId: "demo-no-project",
    firestore: {
      rules: readFileSync("../firestore.rules", "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe("FlexiNode Firestore Security Rules", () => {
  // Helpers
  const getAuthContext = (uid) => testEnv.authenticatedContext(uid);
  const getUnauthContext = () => testEnv.unauthenticatedContext();

  describe("Deliveries Collection", () => {
    it("hanya mengizinkan receiver melihat paketnya sendiri", async () => {
      const aliceContext = getAuthContext("alice123");
      const db = aliceContext.firestore();

      // Setup bypass
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("deliveries").doc("paket_001").set({
          receiverId: "alice123",
          status: "on_delivery"
        });
      });

      // Alice membaca paketnya -> harus berhasil
      const docRef = db.collection("deliveries").doc("paket_001");
      await assertSucceeds(docRef.get());

      // Bob membaca paket Alice -> harus gagal
      const bobContext = getAuthContext("bob456");
      const bobDb = bobContext.firestore();
      await assertFails(bobDb.collection("deliveries").doc("paket_001").get());
    });

    it("tidak mengizinkan unauthenticated membaca paket", async () => {
      const unauthDb = getUnauthContext().firestore();
      await assertFails(unauthDb.collection("deliveries").doc("paket_001").get());
    });
  });

  describe("Nodes Collection", () => {
    it("mengizinkan semua user terotentikasi membaca", async () => {
      const db = getAuthContext("user1").firestore();
      await assertSucceeds(db.collection("nodes").doc("node_001").get());
    });

    it("tidak mengizinkan client app menulis/mengubah data node", async () => {
      const db = getAuthContext("user1").firestore();
      await assertFails(db.collection("nodes").doc("node_001").set({ capacity: 10 }));
    });
  });

  describe("Offers Collection", () => {
    it("hanya mengizinkan receiver melihat penawarannya", async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("offers").doc("offer_001").set({
          receiverId: "alice123",
          status: "pending"
        });
      });

      const aliceDb = getAuthContext("alice123").firestore();
      await assertSucceeds(aliceDb.collection("offers").doc("offer_001").get());

      const bobDb = getAuthContext("bob456").firestore();
      await assertFails(bobDb.collection("offers").doc("offer_001").get());
    });

    it("tidak mengizinkan client app untuk write ke offers", async () => {
      const aliceDb = getAuthContext("alice123").firestore();
      await assertFails(aliceDb.collection("offers").doc("offer_002").set({
        receiverId: "alice123"
      }));
    });
  });

  describe("AI_message Collection", () => {
    it("hanya mengizinkan receiver melihat riwayat pesannya sendiri", async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("AI_message").doc("msg_001").set({
          receiverId: "alice123",
          message: "Halo"
        });
      });

      const aliceDb = getAuthContext("alice123").firestore();
      await assertSucceeds(aliceDb.collection("AI_message").doc("msg_001").get());

      const bobDb = getAuthContext("bob456").firestore();
      await assertFails(bobDb.collection("AI_message").doc("msg_001").get());
    });

    it("tidak mengizinkan write langsung ke AI_message (karena menggunakan REST API)", async () => {
      const aliceDb = getAuthContext("alice123").firestore();
      await assertFails(aliceDb.collection("AI_message").add({
        receiverId: "alice123",
        message: "Saya coba inject pesan palsu"
      }));
    });
  });
});
