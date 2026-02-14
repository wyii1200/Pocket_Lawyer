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


## Impact


## License



     
