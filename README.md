# 📱 Pocket Lawyer

## Project Overview
**Pocket Lawyer** is a mobile/web application designed to assist users with legal document analysis, legal inquiries, and document generation. It provides an interactive dashboard for uploading documents, chatting with a legal chatbot, and generating letters/forms automatically.

**Problem Statement:**
Many users face difficulty understanding legal documents or generating legal letters without professional help. Pocket Lawyer aims to bridge this gap by providing automated, AI-assisted legal support.

**SDGs Tackled (Target):**
- **Goal 16:** Peace, Justice, and Strong Institutions – making legal information more accessible
- **Goal 9:** Industry, Innovation, and Infrastructure – leveraging AI and technology to improve legal services.



## Key Features
- **Home Dashboard:** Access Analyze Document, Chat, and Generate Letter functionalities.  
- **Document Upload:** Supports PDF and image files for analysis.  
- **Legal Chatbot:** Interactive chat interface for legal inquiries.  
- **Form-Based Input:** Easy form creation for generating legal documents.  
- **Results View:** Displays generated documents and analysis results clearly.



## System Flow / Implementation Details
1. User Interaction: Users access the dashboard, upload documents, or initiate chat.
2. Backend Processing: Uploaded documents are sent to Firebase Functions; AI models process data.
3. AI Analysis & Chat: Gemini or other AI services provide document insights and chat responses
4. Document Generation: Users fill form-based inputs; generated letters are stored and displayed
5. Results View: Users can download or view documents with analysis summaries.



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

### Backend (Firebase Emulator)

1. Navigate to backend folder:
   ```bash
    cd pocket-lawyer-backend/functions

2. Start Firebase emulator:
   ```bash
    firebase emulators:start --import=./emulator_data --export-on-exit
3. Test endpoints via Postman (*optional*).

4. Check browser at: http://localhost:4000/firestore to see emulator data in real-time.


## Challenges Faced


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

**1. Accessible Legal Guidance**
The system replaces the need to browse static, complex government websites with a conversational interface where users get legally-referenced replies in plain English within minutes.

**2. Empowered Action through Documentation**
Unlike generic templates, the AI drafts customized, professionally formatted Letters of Demand and formal notices tailored to a user’s specific dispute.

**3. Bridging the Legal Literacy Gap**
By centralizing and simplifying scattered Malaysian laws, the solution ensures that language is no longer a barrier for the B40 community and students seeking justice.

**4. Evidence-Based Trust**
The integration of a RAG pipeline ensures that every AI response is anchored in verified Malaysian statutes, moving the user experience from "AI guessing" to grounded legal truth.

**5. Immediate Crisis Support**
The platform achieves a significant reduction in the time required to understand legal rights, enabling users to move from confusion to clear action steps in under two minutes.

## License

This project is licensed under the MIT License.

Copyright (c) 2026 kamihack

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.


     
