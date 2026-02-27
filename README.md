# 📱 Pocket Lawyer

## Project Overview
**Pocket Lawyer** is a mobile application designed to assist users with legal document analysis, legal inquiries, and document generation. It provides an interactive dashboard for uploading documents, chatting with a legal chatbot, and generating letters/forms automatically.

**Problem Statement:**
Many users face difficulty understanding legal documents or generating legal letters without professional help. Pocket Lawyer aims to bridge this gap by providing automated, AI-assisted legal support.

**SDGs Tackled (Target):**
- **Goal 16:** Peace, Justice, and Strong Institutions – making legal information more accessible
- **Goal 9:** Industry, Innovation, and Infrastructure – leveraging AI and technology to improve legal services.

**Our solution:**
By leveraging Gemini 2.5 Flash and a RAG pipeline grounded in Malaysian statutes, the solution can analyze contracts for "red flags," answer legal queries via a chatbot, and generate professional legal letters. This end-to-end approach addresses SDG 16 by ensuring equal access to justice and reducing the cost barriers associated with traditional legal consultations.


## Key Features
- **Home Dashboard:** Access Analyze Document, Chat, and Generate Letter functionalities.  
- **Document Upload:** Supports PDF and image files for analysis.  
- **Legal Chatbot:** Interactive chat interface for legal inquiries.  
- **Form-Based Input:** Easy form creation for generating legal documents.  
- **Results View:** Displays generated documents and analysis results clearly.


## Overview of Technologies used
**Google Technologies**
- **Gemini 2.5 Flash:** A fast, cost-effective multimodal LLM used for legal reasoning, contract summarization, and RAG-based chat.
- **Flutter (Dart):** The cross-platform UI framework used to build a consistent mobile experience for both Android and iOS.
- **Cloud Firestore:** A NoSQL database that stores user data, chat history, and the curated Malaysian law snippets used for the RAG component.
- **Firebase Cloud Functions:** A serverless backend that hosts the core logic for RAG processing, API calls, and legal context validation.
- **Firebase Storage:** Secure object storage for user-uploaded PDFs/images and the final generated legal documents.
- **Firebase Authentication:** Manages secure user account creation and session persistence.

**Supporting Tools & Libraries**
- **pdf-parse / pdfkit:** Node.js libraries used within Cloud Functions to extract text from user-uploaded PDFs and generate formatted legal letters as PDFs.
- **GitHub:** Utilized for version control, branch management, and collaborative code reviews.
- **Postman:** Employed for rigorous testing of backend API endpoints.
- **Android Emulator:** Used for local environment testing of the mobile application.

## Implementation Details & Innovation
**System Architecture**
- **Frontend (Flutter):** Cross-platform mobile UI for user interactions, document uploads, and displaying AI guidance.
- **Backend (Cloud Functions):** Secure serverless layer that orchestrates RAG logic and manages Gemini API calls.
- **AI Engine (Gemini 2.5 Flash + RAG):** Multimodal LLM providing legal reasoning grounded in Malaysian statutes to prevent hallucinations.
- **Data Storage (Firestore & Storage):** Firestore handles the RAG knowledge base and user history, while Storage hosts PDFs and generated letters.
- **Auth & Analytics (Firebase):** Manages secure user sessions and tracks usage metrics to measure social impact.

**Workflow**
1. **User Interaction:** Users access the dashboard, upload documents, or initiate chat.
2. **Backend Processing:** Uploaded documents are sent to Firebase Functions; Gemini 2.5 Flash processes data.
3. **AI Analysis & Chat:** Gemini provide document insights and chat responses
4. **Document Generation:** Users fill form-based inputs; generated letters are stored and displayed
5. **Results View:** Users can download or view documents with analysis summaries.


## How to Run

### Frontend (Flutter)

1. Clone Repository:
   ```bash
    git clone <repo-url>
    cd pocket-lawyer

2. Install Frontend Dependencies:
   ```bash
    flutter pub get

3. Enable Developer Mode / Tools

   **Windows**
   - Open Settings → System → Advanced
   - Scroll to For developers section
   - Toggle Developer Mode to On
   - Allows installation of apps from any source and enables debugging

   **macOS**
   - Open System Settings → Privacy & Security
   - Scroll to Developer Tools
   - Allow Flutter and your IDE to run apps and debugging
   - Ensure Terminal/IDE has permissions for local app execution

   **Linux**
   - Ensure Flutter SDK is installed and added to PATH
   - Install required packages (Ubuntu example):
     ```bash
      sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   - Ensure your user can run apps and access local devices

4. Run Flutter App
   ```bash
    flutter run


## Challenges Faced
**1. Cross-Platform Integration: Flutter Web & Firebase Storage**
- During development, the document upload feature failed silently on Flutter Web. The system, originally architected for mobile, relied on dart:io and putFile() APIs, which are unsupported in web environments. This created a "black box" failure where the UI would reset without providing error feedback or logs.

**2. AI Pipeline Stability & Resource Constraints**
- Integrating a full OCR (Optical Character Recognition) pipeline for PDF analysis posed significant risks regarding Cloud Function memory limits, execution time, and Gemini API quota management during the intensive 19-day hackathon sprint.


## Future Roadmap
**Short-Term (0-6 Months)**
1. Strengthening Accuracy, Trust & Beta Validation
   - Improve Legal Accuracy and Reliability

**Medium-Term (6-12 Months)**
1. Collaborate with Universities and Legal Aid Clinics
   - Partner with 2-3 university legal aid clinics
2. NGO & Community Organization Integration
   - Collaborate with consumer rights NGOs, tenant associations and migrant support groups.
  
**Long-Term (12+ Months)**
1. Government Pilot Program (Limited Scope)
   - Propose pilot collaboration with one municipal council or consumer complaint office.
2. Sustainable Growth Model
   - Introduce a freemium structure (basic chat free, advanced contract review premium)
3. Selective Regional Adaptation (optional)
   - Adapt legal database for one neighboring country (e.g., Indonesia).


## Impact
**1. Accessible Legal Guidance:**
The system replaces the need to browse static, complex government websites with a conversational interface where users get legally-referenced replies in plain English within minutes.

**2. Empowered Action through Documentation:**
Unlike generic templates, the AI drafts customized, professionally formatted Letters of Demand and formal notices tailored to a user’s specific dispute.

**3. Bridging the Legal Literacy Gap:**
By centralizing and simplifying scattered Malaysian laws, the solution ensures that language is no longer a barrier for the B40 community and students seeking justice.

**4. Evidence-Based Trust:**
The integration of a RAG pipeline ensures that every AI response is anchored in verified Malaysian statutes, moving the user experience from "AI guessing" to grounded legal truth.

**5. Immediate Crisis Support:**
The platform achieves a significant reduction in the time required to understand legal rights, enabling users to move from confusion to clear action steps in under two minutes.


## License
This project is licensed under the MIT License.

Copyright (c) 2026 kamihack

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.


     
