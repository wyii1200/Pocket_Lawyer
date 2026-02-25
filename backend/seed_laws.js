

const admin = require("firebase-admin");

admin.initializeApp({ projectId: "pocketlawyer-ai-2025" });

// Point to emulator
process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";

const db = admin.firestore();

const laws = [
  {
    title: "Contracts Act 1950",
    section: "Section 10",
    content: "All agreements are contracts if made by free consent of parties competent to contract, for a lawful consideration and with a lawful object."
  },
  {
    title: "Contracts Act 1950",
    section: "Section 40",
    content: "When a party to a contract has refused to perform or disabled himself from performing his promise in its entirety, the promisee may put an end to the contract."
  },
  {
    title: "Contracts Act 1950",
    section: "Section 57",
    content: "An agreement to do an act impossible in itself is void. A contract becomes void when the act becomes impossible or unlawful after it is made."
  },
  {
    title: "Employment Act 1955",
    section: "Section 12",
    content: "Either party to a contract of service may terminate the contract by giving notice."
  },
  {
    title: "National Land Code 1965",
    section: "Section 206",
    content: "Any dealing with land or any undivided share in land shall be effected only through the execution of the appropriate instrument."
  },
];

async function seed() {
  for (const law of laws) {
    await db.collection("laws").add(law);
    console.log("Added:", law.title, law.section);
  }
  console.log("Done!");
  process.exit(0);
}

seed();