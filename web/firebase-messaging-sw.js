importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
 apiKey: "AIzaSyCTu_2F12g8w6IGUDw652bLRpM89bzYs9A",
      authDomain: "art-gallery-58f26.firebaseapp.com",
      projectId: "art-gallery-58f26",
      storageBucket: "art-gallery-58f26.firebasestorage.app",
      messagingSenderId: "485834652845",
      appId: "1:485834652845:web:b49fb3c236d452b3315a24",
      measurementId: "G-FX0BD98CF1"

});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
