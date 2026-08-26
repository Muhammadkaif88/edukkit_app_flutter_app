import React, { useEffect, useState, useMemo } from 'react';
import { Link } from 'react-router-dom';
import {
  fetchAdminUsers,
  updateUserRole,
  fetchUserEntitlements,
  grantCourseEntitlement,
  revokeCourseEntitlement,
} from '../api/users';
import { fetchAdminCourses } from '../api/courses';
import { UserProfile, UserRole, CourseEntitlement, Course } from '../types';
import { formatDate } from '../utils/format';
import { useToast } from '../context/ToastContext';
import {
  Users,
  Search,
  CheckCircle2,
  Shield,
  GraduationCap,
  Briefcase,
  AlertTriangle,
  RefreshCw,
  Eye,
  Copy,
  ChevronLeft,
  ChevronRight,
  UserCheck,
  Plus,
  Trash2,
  Key,
  Layers,
} from 'lucide-react';
import { Badge } from '../components/Badge';
import { Modal } from '../components/Modal';
import { Button } from '../components/Button';
import { PageHeader } from '../components/PageHeader';
import { EmptyState } from '../components/EmptyState';
import { TableSkeleton } from '../components/LoadingSkeleton';

export const UsersPage: React.FC = () => {
  const toast = useToast();
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [totalUsers, setTotalUsers] = useState(0);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedRole, setSelectedRole] = useState<string>('all');
  const [page, setPage] = useState(1);
  const pageSize = 20;

  // User Details & Entitlements Inspector State
  const [inspectingUser, setInspectingUser] = useState<UserProfile | null>(null);
  const [userEntitlements, setUserEntitlements] = useState<CourseEntitlement[]>([]);
  const [loadingEntitlements, setLoadingEntitlements] = useState(false);

  // Role Change Modal State
  const [roleChangeUser, setRoleChangeUser] = useState<UserProfile | null>(null);
  const [newRole, setNewRole] = useState<UserRole>('student');
  const [roleSubmitting, setRoleSubmitting] = useState(false);

  // Grant Entitlement Modal State (inside inspector)
  const [isGrantOpen, setIsGrantOpen] = useState(false);
  const [selectedCourseId, setSelectedCourseId] = useState<number | null>(null);
  const [grantSubmitting, setGrantSubmitting] = useState(false);

  // Revoke Entitlement State
  const [revokingEntitlement, setRevokingEntitlement] = useState<CourseEntitlement | null>(null);
  const [revokeSubmitting, setRevoteSubmitting] = useState(false);

  const loadUsers = async () => {
    setLoading(true);
    try {
      const [usersData, coursesData] = await Promise.all([
        fetchAdminUsers({
          role: selectedRole !== 'all' ? (selectedRole as UserRole) : undefined,
          search: search || undefined,
          limit: pageSize,
          offset: (page - 1) * pageSize,
        }),
        fetchAdminCourses().catch(() => []),
      ]);
      setUsers(usersData.users || []);
      setTotalUsers(usersData.total || 0);
      setCourses(coursesData);
    } catch (err: any) {
      toast.error('Failed to load users', err?.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, [page, selectedRole]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    loadUsers();
  };

  const copyToClipboard = (text: string, label: string = 'Text') => {
    navigator.clipboard.writeText(text);
    toast.info('Copied to Clipboard', `${label}: ${text}`);
  };

  // --------------------------------------------------------------------------
  // USER METRICS (Dynamic from loaded users & totals)
  // --------------------------------------------------------------------------
  const userMetrics = useMemo(() => {
    const total = totalUsers || users.length;
    const students = users.filter((u) => u.role === 'student').length;
    const teachers = users.filter((u) => u.role === 'teacher').length;
    const admins = users.filter((u) => u.role === 'admin' || u.role === 'staff').length;
    const verified = users.filter((u) => u.is_verified).length;
    return { total, students, teachers, admins, verified };
  }, [users, totalUsers]);

  // --------------------------------------------------------------------------
  // USER DETAILS & ENTITLEMENTS INSPECTOR
  // --------------------------------------------------------------------------
  const openUserDetail = async (user: UserProfile) => {
    setInspectingUser(user);
    setLoadingEntitlements(true);
    try {
      const entitlements = await fetchUserEntitlements(user.id);
      setUserEntitlements(entitlements);
    } catch (err: any) {
      console.error('Failed to load user entitlements:', err);
    } finally {
      setLoadingEntitlements(false);
    }
  };

  // --------------------------------------------------------------------------
  // ROLE UPDATE HANDLER
  // --------------------------------------------------------------------------
  const openRoleChangeModal = (user: UserProfile) => {
    setRoleChangeUser(user);
    setNewRole(user.role);
  };

  const handleRoleChangeSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!roleChangeUser) return;
    if (roleChangeUser.role === newRole) {
      setRoleChangeUser(null);
      return;
    }

    setRoleSubmitting(true);
    try {
      await updateUserRole(roleChangeUser.id, newRole);
      toast.success(
        'User Role Updated',
        `${roleChangeUser.name || roleChangeUser.email} is now a ${newRole.toUpperCase()}.`
      );

      // Update state
      setUsers((prev) =>
        prev.map((u) => (u.id === roleChangeUser.id ? { ...u, role: newRole } : u))
      );
      if (inspectingUser && inspectingUser.id === roleChangeUser.id) {
        setInspectingUser({ ...inspectingUser, role: newRole });
      }
      setRoleChangeUser(null);
    } catch (err: any) {
      toast.error('Role Update Failed', err?.message);
    } finally {
      setRoleSubmitting(false);
    }
  };

  // --------------------------------------------------------------------------
  // GRANT ENTITLEMENT (Inside Inspector)
  // --------------------------------------------------------------------------
  const handleGrantSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inspectingUser || !selectedCourseId) return;

    setGrantSubmitting(true);
    try {
      await grantCourseEntitlement(inspectingUser.id, selectedCourseId, 'MANUAL_ADMIN_GRANT');
      toast.success('Access Granted', `Course access granted to ${inspectingUser.email}.`);
      setIsGrantOpen(false);
      setSelectedCourseId(null);
      const updated = await fetchUserEntitlements(inspectingUser.id);
      setUserEntitlements(updated);
    } catch (err: any) {
      toast.error('Grant Failed', err?.message);
    } finally {
      setGrantSubmitting(false);
    }
  };

  // --------------------------------------------------------------------------
  // REVOKE ENTITLEMENT
  // --------------------------------------------------------------------------
  const handleRevokeSubmit = async () => {
    if (!inspectingUser || !revokingEntitlement) return;

    setRevoteSubmitting(true);
    try {
      await revokeCourseEntitlement(inspectingUser.id, revokingEntitlement.course_id);
      toast.success('Access Revoked', `Course access removed for ${inspectingUser.email}.`);
      setRevokingEntitlement(null);
      const updated = await fetchUserEntitlements(inspectingUser.id);
      setUserEntitlements(updated);
    } catch (err: any) {
      toast.error('Revocation Failed', err?.message);
    } finally {
      setRevoteSubmitting(false);
    }
  };

  const getRoleBadge = (role: UserRole) => {
    switch (role) {
      case 'admin':
        return (
          <Badge variant="purple" size="sm" className="gap-1 items-center font-bold">
            <Shield size={12} />
            <span>Admin</span>
          </Badge>
        );
      case 'staff':
        return (
          <Badge variant="purple" size="sm" className="gap-1 items-center font-bold">
            <Key size={12} />
            <span>Staff</span>
          </Badge>
        );
      case 'teacher':
        return (
          <Badge variant="info" size="sm" className="gap-1 items-center font-bold">
            <Briefcase size={12} />
            <span>Teacher</span>
          </Badge>
        );
      default:
        return (
          <Badge variant="success" size="sm" className="gap-1 items-center">
            <GraduationCap size={12} />
            <span>Student</span>
          </Badge>
        );
    }
  };

  const getCourseTitle = (courseId: number) => {
    const course = courses.find((c) => c.id === courseId);
    return course ? course.title : `Course #${courseId}`;
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <PageHeader
        title="User & Access Directory"
        subtitle="Manage learner profiles, staff credentials, RBAC roles, and individual course enrollments"
        breadcrumbs={[{ label: 'Admin', href: '/' }, { label: 'Users' }]}
        action={
          <div className="flex items-center gap-2.5">
            <button
              onClick={loadUsers}
              className="p-2 bg-white hover:bg-slate-50 border border-slate-200 rounded-lg text-slate-600 hover:text-slate-900 transition-colors shadow-2xs cursor-pointer"
              title="Refresh User Directory"
            >
              <RefreshCw size={15} />
            </button>
            <Link
              to="/entitlements"
              className="px-3 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-semibold rounded-lg text-xs flex items-center gap-1.5 transition-colors"
            >
              <Layers size={15} />
              <span>Entitlements Hub</span>
            </Link>
          </div>
        }
      />

      {/* KPI Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3.5">
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500">Total Users</span>
            <Users size={16} className="text-indigo-600" />
          </div>
          <p className="text-2xl font-bold text-slate-900 mt-1.5">{userMetrics.total}</p>
          <span className="text-[11px] text-slate-400">All registered accounts</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500">Students</span>
            <GraduationCap size={16} className="text-emerald-600" />
          </div>
          <p className="text-2xl font-bold text-emerald-600 mt-1.5">{userMetrics.students}</p>
          <span className="text-[11px] text-slate-400">Active learners</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500">Teachers</span>
            <Briefcase size={16} className="text-sky-600" />
          </div>
          <p className="text-2xl font-bold text-sky-600 mt-1.5">{userMetrics.teachers}</p>
          <span className="text-[11px] text-slate-400">Instructors & Mentors</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500">Admins & Staff</span>
            <Shield size={16} className="text-purple-600" />
          </div>
          <p className="text-2xl font-bold text-purple-600 mt-1.5">{userMetrics.admins}</p>
          <span className="text-[11px] text-purple-700 font-medium">Elevated RBAC</span>
        </div>
      </div>

      {/* Search & Role Filters */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs space-y-3">
        <form onSubmit={handleSearchSubmit} className="flex flex-col sm:flex-row items-center gap-3">
          <div className="relative flex-1 w-full">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by name, email, phone, or Firebase UID..."
              className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs sm:text-sm focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto">
            <select
              value={selectedRole}
              onChange={(e) => {
                setSelectedRole(e.target.value);
                setPage(1);
              }}
              className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="all">All Roles</option>
              <option value="student">Students</option>
              <option value="teacher">Teachers</option>
              <option value="admin">Admins</option>
              <option value="staff">Staff</option>
            </select>

            <Button type="submit" variant="secondary" size="sm">
              Search
            </Button>
          </div>
        </form>
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-2xs overflow-hidden">
        {loading ? (
          <TableSkeleton rows={6} />
        ) : users.length === 0 ? (
          <EmptyState
            icon={Users}
            title="No users found"
            description={
              search || selectedRole !== 'all'
                ? 'No user accounts matched your search criteria.'
                : 'No registered user accounts found in database.'
            }
          />
        ) : (
          <div className="divide-y divide-slate-100">
            {users.map((user) => (
              <div
                key={user.id}
                className="p-4 sm:px-6 flex flex-col md:flex-row md:items-center justify-between gap-4 hover:bg-slate-50/75 transition-colors"
              >
                {/* Left: Avatar & Identity */}
                <div className="flex items-center gap-3.5 min-w-0">
                  {user.profile_image ? (
                    <img
                      src={user.profile_image}
                      alt=""
                      onClick={() => openUserDetail(user)}
                      className="w-11 h-11 rounded-full object-cover border border-slate-200 shrink-0 cursor-pointer shadow-2xs"
                    />
                  ) : (
                    <div
                      onClick={() => openUserDetail(user)}
                      className="w-11 h-11 rounded-full bg-indigo-50 text-indigo-700 border border-indigo-100 flex items-center justify-center font-bold text-sm shrink-0 cursor-pointer"
                    >
                      {(user.name || user.email || 'U')[0].toUpperCase()}
                    </div>
                  )}

                  <div className="min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <button
                        onClick={() => openUserDetail(user)}
                        className="font-bold text-slate-900 hover:text-indigo-600 text-sm truncate text-left transition-colors cursor-pointer"
                      >
                        {user.name || 'Unnamed Account'}
                      </button>
                      {user.is_verified && (
                        <span title="Verified Account">
                          <CheckCircle2 size={14} className="text-emerald-600 shrink-0" />
                        </span>
                      )}
                    </div>

                    <div className="flex items-center gap-2.5 text-xs text-slate-500 mt-1 flex-wrap">
                      <span className="truncate max-w-[170px]">{user.email}</span>
                      {user.phone && (
                        <>
                          <span>&bull;</span>
                          <span>{user.phone}</span>
                        </>
                      )}
                      {user.firebase_uid && (
                        <>
                          <span>&bull;</span>
                          <button
                            onClick={() => copyToClipboard(user.firebase_uid, 'UID')}
                            className="font-mono text-[11px] text-slate-400 hover:text-slate-700 flex items-center gap-1 cursor-pointer"
                            title="Click to copy Firebase UID"
                          >
                            <span>{user.firebase_uid.substring(0, 10)}...</span>
                            <Copy size={11} />
                          </button>
                        </>
                      )}
                      {user.created_at && (
                        <>
                          <span>&bull;</span>
                          <span>{formatDate(user.created_at)}</span>
                        </>
                      )}
                    </div>
                  </div>
                </div>

                {/* Middle: Role Badge & Verification */}
                <div className="flex items-center gap-3 shrink-0 flex-wrap">
                  {getRoleBadge(user.role)}
                  {user.approval_status && user.approval_status !== 'pending' && (
                    <Badge variant={user.approval_status === 'approved' ? 'success' : 'danger'} size="sm">
                      {user.approval_status}
                    </Badge>
                  )}
                </div>

                {/* Right: Actions */}
                <div className="flex items-center justify-end gap-1.5 shrink-0">
                  <button
                    onClick={() => openUserDetail(user)}
                    className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-md transition-colors cursor-pointer"
                    title="Inspect Profile & Course Entitlements"
                  >
                    <Eye size={16} />
                  </button>

                  <button
                    onClick={() => openRoleChangeModal(user)}
                    className="px-2.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-md text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer"
                    title="Change Account Role"
                  >
                    <UserCheck size={13} />
                    <span>Change Role</span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Pagination Footer */}
        {totalUsers > pageSize && (
          <div className="px-6 py-3 border-t border-slate-100 bg-slate-50 flex items-center justify-between text-xs text-slate-600">
            <span>
              Showing {(page - 1) * pageSize + 1} - {Math.min(page * pageSize, totalUsers)} of {totalUsers} accounts
            </span>
            <div className="flex items-center gap-2">
              <Button
                variant="secondary"
                size="sm"
                disabled={page <= 1}
                onClick={() => setPage(page - 1)}
                leftIcon={<ChevronLeft size={14} />}
              >
                Previous
              </Button>
              <Button
                variant="secondary"
                size="sm"
                disabled={page * pageSize >= totalUsers}
                onClick={() => setPage(page + 1)}
                rightIcon={<ChevronRight size={14} />}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </div>

      {/* ── 1. USER DETAILS & ENTITLEMENTS INSPECTOR MODAL ────────────────── */}
      <Modal
        isOpen={!!inspectingUser}
        onClose={() => setInspectingUser(null)}
        title={inspectingUser?.name || inspectingUser?.email || 'User Profile'}
        subtitle="Account identity, authentication metadata, and active course entitlements"
        maxWidth="xl"
      >
        {inspectingUser && (
          <div className="space-y-5 text-xs">
            {/* Identity Card */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 p-4 bg-slate-50 rounded-xl border border-slate-200">
              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Account ID</span>
                <p className="font-mono font-bold text-slate-800 mt-0.5">#{inspectingUser.id}</p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Assigned Role</span>
                <div className="mt-1">{getRoleBadge(inspectingUser.role)}</div>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Email Address</span>
                <p className="font-semibold text-slate-800 mt-0.5">{inspectingUser.email}</p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Phone Number</span>
                <p className="font-semibold text-slate-800 mt-0.5">{inspectingUser.phone || 'N/A'}</p>
              </div>

              <div className="sm:col-span-2">
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Firebase Auth UID</span>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <code className="font-mono text-slate-800 bg-white px-2 py-0.5 rounded border border-slate-200">
                    {inspectingUser.firebase_uid || 'No Firebase UID attached'}
                  </code>
                  {inspectingUser.firebase_uid && (
                    <button
                      onClick={() => copyToClipboard(inspectingUser.firebase_uid, 'UID')}
                      className="text-slate-400 hover:text-slate-700 p-1 cursor-pointer"
                      title="Copy UID"
                    >
                      <Copy size={13} />
                    </button>
                  )}
                </div>
              </div>
            </div>

            {/* Course Entitlements Section */}
            <div className="p-4 bg-white rounded-xl border border-slate-200 shadow-2xs space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-indigo-700 font-bold">
                  <Layers size={15} />
                  <span>Enrolled Course Access ({userEntitlements.length})</span>
                </div>
                <Button
                  size="sm"
                  leftIcon={<Plus size={14} />}
                  onClick={() => setIsGrantOpen(true)}
                >
                  Grant Course
                </Button>
              </div>

              {loadingEntitlements ? (
                <p className="text-slate-400 italic py-2">Loading course entitlements...</p>
              ) : userEntitlements.length === 0 ? (
                <div className="p-4 bg-slate-50 rounded-xl text-center text-slate-500 text-xs">
                  This user has no active or past course entitlements.
                </div>
              ) : (
                <div className="divide-y divide-slate-100">
                  {userEntitlements.map((e) => (
                    <div key={e.id} className="py-2.5 flex items-center justify-between gap-3">
                      <div className="min-w-0">
                        <p className="font-bold text-slate-900 truncate">{getCourseTitle(e.course_id)}</p>
                        <div className="flex items-center gap-2 text-[11px] text-slate-500 mt-0.5">
                          <span className="font-mono">Course #{e.course_id}</span>
                          <span>&bull;</span>
                          <span>{e.order_id || 'Admin Grant'}</span>
                          {e.granted_at && (
                            <>
                              <span>&bull;</span>
                              <span>{formatDate(e.granted_at)}</span>
                            </>
                          )}
                        </div>
                      </div>

                      <div className="flex items-center gap-2 shrink-0">
                        <Badge
                          variant={e.status === 'ACTIVE' ? 'success' : 'danger'}
                          size="sm"
                        >
                          {e.status}
                        </Badge>
                        {e.status === 'ACTIVE' && (
                          <button
                            onClick={() => setRevokingEntitlement(e)}
                            className="p-1 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded transition-colors cursor-pointer"
                            title="Revoke Course Access"
                          >
                            <Trash2 size={14} />
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <div className="flex justify-end pt-2">
              <Button variant="secondary" onClick={() => setInspectingUser(null)}>
                Close
              </Button>
            </div>
          </div>
        )}
      </Modal>

      {/* ── 2. ROLE CHANGE CONFIRMATION MODAL ─────────────────────────────── */}
      <Modal
        isOpen={!!roleChangeUser}
        onClose={() => setRoleChangeUser(null)}
        title="Update User Role"
        subtitle={`Modify authorization privileges for '${roleChangeUser?.name || roleChangeUser?.email}'`}
        maxWidth="md"
      >
        <form onSubmit={handleRoleChangeSubmit} className="space-y-4">
          <div className="p-3.5 bg-amber-50 border border-amber-200 rounded-xl text-amber-900 text-xs flex items-start gap-2.5">
            <AlertTriangle size={18} className="text-amber-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Role Escalation Notice</p>
              <p className="mt-0.5">
                Elevating a user to <strong>Admin</strong> or <strong>Staff</strong> grants administrative privileges. Backend RBAC is authoritative.
              </p>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">Select New Role</label>
            <select
              value={newRole}
              onChange={(e) => setNewRole(e.target.value as UserRole)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white font-semibold text-slate-800 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
            >
              <option value="student">Student (Standard Learner)</option>
              <option value="teacher">Teacher (Instructor)</option>
              <option value="admin">Admin (Full Administrative Access)</option>
              <option value="staff">Staff (Staff Operations)</option>
            </select>
          </div>

          <div className="flex justify-end gap-3 pt-3 border-t border-slate-100">
            <Button type="button" variant="secondary" onClick={() => setRoleChangeUser(null)}>
              Cancel
            </Button>
            <Button type="submit" isLoading={roleSubmitting}>
              Confirm Role Change
            </Button>
          </div>
        </form>
      </Modal>

      {/* ── 3. GRANT COURSE ENTITLEMENT MODAL ─────────────────────────────── */}
      <Modal
        isOpen={isGrantOpen}
        onClose={() => setIsGrantOpen(false)}
        title="Grant Course Access"
        subtitle={`Provide enrollment access to '${inspectingUser?.name || inspectingUser?.email}'`}
        maxWidth="md"
      >
        <form onSubmit={handleGrantSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">Select Target Course *</label>
            <select
              value={selectedCourseId || ''}
              onChange={(e) => setSelectedCourseId(Number(e.target.value))}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              required
            >
              <option value="">-- Choose a course --</option>
              {courses.map((c) => (
                <option key={c.id} value={c.id}>
                  #{c.id} - {c.title} ({c.is_published ? 'Live' : 'Draft'})
                </option>
              ))}
            </select>
          </div>

          <div className="flex justify-end gap-3 pt-3 border-t border-slate-100">
            <Button type="button" variant="secondary" onClick={() => setIsGrantOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={!selectedCourseId} isLoading={grantSubmitting}>
              Grant Access
            </Button>
          </div>
        </form>
      </Modal>

      {/* ── 4. REVOKE COURSE ENTITLEMENT CONFIRMATION MODAL ───────────────── */}
      <Modal
        isOpen={!!revokingEntitlement}
        onClose={() => setRevokingEntitlement(null)}
        title="Revoke Course Entitlement"
        subtitle="Remove learner access from course curriculum"
        maxWidth="md"
      >
        <div className="space-y-4 text-xs sm:text-sm text-slate-600">
          <div className="p-3.5 bg-rose-50 border border-rose-200 rounded-xl text-rose-800 text-xs flex items-start gap-2.5">
            <AlertTriangle size={18} className="text-rose-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Revoke Course Access</p>
              <p className="mt-0.5">
                Are you sure you want to revoke access to{' '}
                <strong>"{revokingEntitlement ? getCourseTitle(revokingEntitlement.course_id) : ''}"</strong> for{' '}
                {inspectingUser?.email}? The student will immediately lose access to paid lessons.
              </p>
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setRevokingEntitlement(null)}>
              Cancel
            </Button>
            <Button variant="danger" isLoading={revokeSubmitting} onClick={handleRevokeSubmit}>
              Confirm Revocation
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};
