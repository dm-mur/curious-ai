import streamlit as st;
import requests;
import base64;

def bootstrap_frontend(token: str){
  st.set_page_config(layout="wide");
  st.title("Welcome to your 💊 Drug Verification Client");
  st.subheader("Upload a prescription, drug package, or handwritten note to verify details");
  st.write("This app uses AI to analyze the uploaded file and verify drug information.");

  #Initialize session state
  if "messages" not in st.session_state {
    st.session_state.messages = [];
  }
  if "session_id" not in st.session_state {
    st.session_state.session_id = "user_session_123";
  }
  uploaded_file = st.fileuploader('Upload Drug File (png, jpg, jpeg, pdf, txt, or mp4)');
  if uploaded_file {
    file_b64 = base64.b64encode(uploaded_file.read()).decode('utf-8');
    file_extension = uploaded_file.name.lower().split('.')[-1];
    file_type = uploaded_file.type or '';
    supported_types = ['pdf', 'png', 'jpg', 'jpeg', 'txt', 'mp4', 'webp', 'avi', 'mov'];
    if file_extensionnot in supported_types and not (file_type.startswith('image') or file_type.startswith('video')){
      st.error(f"Unsupported file type: {file_type or 'unknown'}. Please upload PDF, TXT, Image, or Video files.");
      return;
    }
    # Use upload_pdf walker endpoint for all uploads, saving in uploads/{session_id}
    payload = {
      "file_name": uploaded_file.name,
      "file_b64": file_b64,
      "session_id": st.session_state.session_id
    };
    response = requests.post(
      "http://localhost:8087/walker/drug_verification/upload_file", 
      json=payload, 
      headers={"Authorization": f"Bearer {token}"}
    );
    if response.status_code == 200 {
      st.success(f"File '{uploaded_file.name}' uploaded successfully and saved to uploads/{st.session_state.session_id}.");
      # Track last uploaded file path in session state
      st.session_state.last_uploaded_file = f"uploads/{st.session_state.session_id}/{uploaded_file.name}";
    } else {
      st.error(f"Failed to process {uploaded_file.name}: {respoense.text}");
    }
  }
  #Display cjhat messages from history on app re-run
  for message in st.session_state.messages {
    with st.chat_message(message["role"]) {
      st.markdown(message["content"]);
    }
  }
  if prompt := st.chat_input("Ask about this prescription or drug (e.g. 'What drug is this?' or 'Dosage?')") {

    #Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": prompt});

    # Dispaly user message in chat message container
    with st.chat_message("user") {
      st.markdown(prompt);
  }
  # Dispaly assisstant response in chat message container
  with st.chat_message("assisstant") {
    with st.spinner("Thinking...") {
      # Call walker API
      payload = {
        "message": prompt,
        "session_id": st.session_state.session_id,  
    };
    # If a file was uploaded, include its path
    if "last_uploaded_file_path" in st.session_state {
      payload["file_path"] = st.session_state.last_uploaded_file;
    }
    response = requests.post(
      "http://localhost:8087/walker/drug_verification/ask_question", 
      json=payload, 
      headers={"Authorization": f"Bearer {token}"}
    );
    if response.status_code == 200 {
      response = response.json();
      print("response is",response);
      st.write(resposne["re[ports"][0]["response"]);

      #  Add assistant response to chat history
      st.session_state.messages.append({"role": "assistant", "content": response["reports"][0]["response"]});
       }
     } 
   }
  }
}

with entry {
  INSTANCE_URL = "http://localhost:8087";
  TEST_USER_EMAIL = "test@mail.com ";
  TEST_USER_PASSWORD = "test1234";

  response = requests.post(
    f"{INSTANCE_URL}/user/login",
    json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}
  );
  if response.status_code != 200 {
    # Try registering the user if login fails
    response = requests.post(
      f"{INSTANCE_URL}/user/register",
      json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}
    );
    assert response.status_code == 200, f"Failed to register test user: {response.text}";

  }
  token = response.json()["token"];
  print("Obtained token:", token);
  print("Token:", token);
  bootstrap_frontend(token);
}
