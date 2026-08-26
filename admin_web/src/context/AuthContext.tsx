import React, { createContext, useContext, useEffect, useState } from 'react';
import {
  auth,
  loginWithEmail,
  logout as authLogout,
  onAuthStateChanged,
  FirebaseUser,
  devBypassLogin,
} from '../api/auth';
import { setTokenProvider, setDevToken, getDevToken } from '../api/client';
import { UserProfile } from '../types';

interface AuthContextType {
  user: FirebaseUser | null;
  profile: UserProfile | null;
  loading: boolean;
  isDevMode: boolean;
  login: (email: string, pass: string) => Promise<void>;
  devLogin: (role?: 'admin' | 'teacher' | 'student') => void;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<FirebaseUser | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [isDevMode, setIsDevMode] = useState<boolean>(!!getDevToken());

  // Configure central API client token provider
  useEffect(() => {
    setTokenProvider(async () => {
      const devToken = getDevToken();
      if (devToken) return devToken;
      if (auth.currentUser) {
        return await auth.currentUser.getIdToken();
      }
      return null;
    });
  }, []);

  useEffect(() => {
    // Clear any stale dev tokens — they are rejected by the production backend (APP_ENV=production).
    // Users must sign in with real Firebase credentials to get a valid JWT.
    const storedDevToken = getDevToken();
    if (storedDevToken) {
      console.warn('[Auth] Clearing stale dev bypass token from localStorage (not valid in production).');
      setDevToken(null);
    }

    // Subscribe to Firebase Auth state changes
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setUser(firebaseUser);
      if (firebaseUser) {
        setProfile({
          id: 1,
          firebase_uid: firebaseUser.uid,
          name: firebaseUser.displayName || firebaseUser.email?.split('@')[0] || 'Admin',
          email: firebaseUser.email || 'admin@edukkit.com',
          role: 'admin',
          profile_image: firebaseUser.photoURL || undefined,
        });
      } else {
        setProfile(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const login = async (email: string, pass: string) => {
    setLoading(true);
    try {
      setDevToken(null);
      setIsDevMode(false);
      const loggedUser = await loginWithEmail(email, pass);
      setUser(loggedUser);
      setProfile({
        id: 1,
        firebase_uid: loggedUser.uid,
        name: loggedUser.displayName || loggedUser.email?.split('@')[0] || 'Admin',
        email: loggedUser.email || 'admin@edukkit.com',
        role: 'admin',
      });
    } finally {
      setLoading(false);
    }
  };

  const devLogin = (role: 'admin' | 'teacher' | 'student' = 'admin') => {
    devBypassLogin(role);
    setIsDevMode(true);
    setUser(null);
    setProfile({
      id: 1,
      firebase_uid: `${role}_dev_uid`,
      name: `Developer ${role.toUpperCase()}`,
      email: role === 'admin' ? 'iam@edukkit.com' : `${role}@edukkit.com`,
      role: role,
      is_verified: true,
    });
  };

  const logout = async () => {
    setLoading(true);
    try {
      await authLogout();
      setDevToken(null);
      setIsDevMode(false);
      setUser(null);
      setProfile(null);
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        profile,
        loading,
        isDevMode,
        login,
        devLogin,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
