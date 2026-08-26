// Firebase Web Client & Auth Helpers
import { initializeApp, getApps, getApp } from 'firebase/app';
import {
  getAuth,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  User as FirebaseUser,
} from 'firebase/auth';
import { setDevToken, getDevToken } from './client';
import { UserProfile } from '../types';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

// Initialize Firebase App if not already initialized
export const firebaseApp = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);
export const auth = getAuth(firebaseApp);

export async function loginWithEmail(email: string, pass: string): Promise<FirebaseUser> {
  // Clear any existing dev token when logging in with real Firebase
  setDevToken(null);
  const cred = await signInWithEmailAndPassword(auth, email, pass);
  return cred.user;
}

export async function logout(): Promise<void> {
  setDevToken(null);
  await firebaseSignOut(auth);
}

export function devBypassLogin(role: 'admin' | 'teacher' | 'student' = 'admin') {
  const token = `dev_${role}_token_local_${Date.now()}`;
  setDevToken(token);
  return token;
}

export async function getCurrentUserProfile(): Promise<UserProfile> {
  const devToken = getDevToken();
  if (devToken && devToken.startsWith('dev_admin_')) {
    return {
      id: 1,
      firebase_uid: 'admin_dev_uid',
      name: 'System Administrator (Dev)',
      email: 'iam@edukkit.com',
      role: 'admin',
      is_verified: true,
      approval_status: 'approved',
    };
  }

  const user = auth.currentUser;
  return {
    id: 1,
    firebase_uid: user?.uid || 'unknown',
    name: user?.displayName || user?.email?.split('@')[0] || 'Admin',
    email: user?.email || 'admin@edukkit.com',
    role: 'admin',
    is_verified: user?.emailVerified || true,
  };
}

export { onAuthStateChanged };
export type { FirebaseUser };
