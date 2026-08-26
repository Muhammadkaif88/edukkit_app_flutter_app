import React from 'react';
import { useAuth } from '../context/AuthContext';
import { BASE_URL } from '../api/client';
import {
  Shield,
  Server,
  Key,
  Database,
  CheckCircle2,
  ExternalLink,
  Lock,
} from 'lucide-react';
import { Badge } from '../components/Badge';

export const SettingsPage: React.FC = () => {
  const { profile, isDevMode } = useAuth();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-extrabold text-slate-900 tracking-tight">System Settings</h1>
        <p className="text-sm text-slate-500 mt-0.5">
          Backend server configuration, video CDN parameters, and security policies
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Administrator Profile Card */}
        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center gap-3 pb-4 border-b border-slate-100">
            <div className="w-10 h-10 rounded-lg bg-indigo-50 text-indigo-600 flex items-center justify-center">
              <Shield size={20} />
            </div>
            <div>
              <h3 className="font-bold text-slate-900 text-base">Active Admin Session</h3>
              <p className="text-xs text-slate-500">Authenticated via Firebase Security Claims</p>
            </div>
          </div>

          <div className="mt-4 space-y-3 text-sm">
            <div className="flex justify-between py-1.5 border-b border-slate-50">
              <span className="text-slate-500">Name:</span>
              <span className="font-semibold text-slate-800">{profile?.name || 'Administrator'}</span>
            </div>
            <div className="flex justify-between py-1.5 border-b border-slate-50">
              <span className="text-slate-500">Email:</span>
              <span className="font-semibold text-slate-800">{profile?.email}</span>
            </div>
            <div className="flex justify-between py-1.5 border-b border-slate-50">
              <span className="text-slate-500">Role:</span>
              <Badge variant="purple" size="sm">
                {profile?.role?.toUpperCase() || 'ADMIN'}
              </Badge>
            </div>
            <div className="flex justify-between py-1.5">
              <span className="text-slate-500">Auth Mode:</span>
              <span className="font-medium text-xs text-slate-700">
                {isDevMode ? 'Developer Bypass Token' : 'Firebase ID Token (Bearer)'}
              </span>
            </div>
          </div>
        </div>

        {/* Backend & Video Security Architecture */}
        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center gap-3 pb-4 border-b border-slate-100">
            <div className="w-10 h-10 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <Server size={20} />
            </div>
            <div>
              <h3 className="font-bold text-slate-900 text-base">FastAPI Commerce Backend</h3>
              <p className="text-xs text-slate-500">Architecture Source of Truth</p>
            </div>
          </div>

          <div className="mt-4 space-y-3 text-sm">
            <div className="flex justify-between py-1.5 border-b border-slate-50">
              <span className="text-slate-500">API Host:</span>
              <code className="text-xs bg-slate-50 px-2 py-0.5 rounded font-mono text-slate-800 max-w-[220px] truncate" title={BASE_URL}>
                {BASE_URL}
              </code>
            </div>
            <div className="flex justify-between py-1.5 border-b border-slate-50">
              <span className="text-slate-500">Interactive OpenAPI Docs:</span>
              <a
                href={`${BASE_URL}/docs`}
                target="_blank"
                rel="noreferrer"
                className="text-xs font-semibold text-indigo-600 hover:text-indigo-700 flex items-center gap-1"
              >
                <span>/docs</span>
                <ExternalLink size={12} />
              </a>
            </div>
            <div className="flex justify-between py-1.5 border-b border-slate-50">
              <span className="text-slate-500">Bunny Video Security:</span>
              <span className="text-xs text-emerald-700 font-medium flex items-center gap-1">
                <CheckCircle2 size={13} />
                <span>Encrypted Server-Side Tokens</span>
              </span>
            </div>
            <div className="flex justify-between py-1.5">
              <span className="text-slate-500">Payment Engine:</span>
              <span className="text-xs font-semibold text-slate-800">Cashfree PG + Webhooks</span>
            </div>
          </div>
        </div>
      </div>

      {/* Security Policies */}
      <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs">
        <h3 className="font-bold text-slate-800 text-base mb-2">Security Enforcement Checklist</h3>
        <p className="text-xs text-slate-500 mb-4">
          All administrative requests adhere to zero-trust server-side validation rules
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 text-xs">
          <div className="p-3.5 rounded-lg bg-slate-50 border border-slate-200">
            <div className="flex items-center gap-2 font-bold text-slate-800 mb-1">
              <Lock size={14} className="text-indigo-600" />
              <span>Token Protected APIs</span>
            </div>
            <p className="text-slate-500">
              Every request carries verified Firebase ID token claims with <code>Authorization: Bearer</code>.
            </p>
          </div>

          <div className="p-3.5 rounded-lg bg-slate-50 border border-slate-200">
            <div className="flex items-center gap-2 font-bold text-slate-800 mb-1">
              <Key size={14} className="text-indigo-600" />
              <span>No Leaked Credentials</span>
            </div>
            <p className="text-slate-500">
              Bunny Stream API keys and Cashfree client secrets are strictly quarantined to the backend.
            </p>
          </div>

          <div className="p-3.5 rounded-lg bg-slate-50 border border-slate-200">
            <div className="flex items-center gap-2 font-bold text-slate-800 mb-1">
              <Database size={14} className="text-indigo-600" />
              <span>Commerce Integrity</span>
            </div>
            <p className="text-slate-500">
              Prices, delivery charges, and digital entitlements are calculated exclusively on server.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
