import React, { useEffect, useState, useMemo } from 'react';
import {
  fetchAdminUsers,
  fetchUserEntitlements,
  grantCourseEntitlement,
  revokeCourseEntitlement,
} from '../api/users';
import { fetchAdminCourses } from '../api/courses';
import { UserProfile, CourseEntitlement, Course } from '../types';
import { formatDate } from '../utils/format';
import { useToast } from '../context/ToastContext';
import {
  Layers,
  Search,
  CheckCircle2,
  AlertTriangle,
  RefreshCw,
  Plus,
  Trash2,
  GraduationCap,
  BookOpen,
  AlertCircle,
} from 'lucide-react';
import { Badge } from '../components/Badge';
import { Modal } from '../components/Modal';
import { Button } from '../components/Button';
import { PageHeader } from '../components/PageHeader';
import { EmptyState } from '../components/EmptyState';
import { TableSkeleton } from '../components/LoadingSkeleton';

export const EntitlementsPage: React.FC = () => {
  const toast = useToast();
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);
  const [entitlements, setEntitlements] = useState<CourseEntitlement[]>([]);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [loadingEntitlements, setLoadingEntitlements] = useState(false);
  const [courseSearch, setCourseSearch] = useState('');

  // Grant Access Modal State
  const [isGrantOpen, setIsGrantOpen] = useState(false);
  const [grantUserId, setGrantUserId] = useState<number | null>(null);
  const [grantCourseId, setGrantCourseId] = useState<number | null>(null);
  const [grantSubmitting, setGrantSubmitting] = useState(false);

  // Revoke Access Modal State
  const [revokingItem, setRevokingItem] = useState<CourseEntitlement | null>(null);
  const [revokeSubmitting, setRevokeSubmitting] = useState(false);

  const loadInitialData = async () => {
    setLoadingUsers(true);
    try {
      const [usersData, coursesData] = await Promise.all([
        fetchAdminUsers({ limit: 100 }),
        fetchAdminCourses(),
      ]);
      setUsers(usersData.users || []);
      setCourses(coursesData);

      if (usersData.users && usersData.users.length > 0) {
        const firstUser = usersData.users[0];
        setSelectedUserId(firstUser.id);
        await loadUserEntitlements(firstUser.id);
      }
    } catch (err: any) {
      toast.error('Failed to load entitlements directory', err?.message);
    } finally {
      setLoadingUsers(false);
    }
  };

  const loadUserEntitlements = async (userId: number) => {
    setLoadingEntitlements(true);
    try {
      const data = await fetchUserEntitlements(userId);
      setEntitlements(data);
    } catch (err: any) {
      toast.error('Failed to load user course access', err?.message);
    } finally {
      setLoadingEntitlements(false);
    }
  };

  useEffect(() => {
    loadInitialData();
  }, []);

  const handleUserChange = async (userId: number) => {
    setSelectedUserId(userId);
    await loadUserEntitlements(userId);
  };

  const selectedUser = useMemo(() => {
    return users.find((u) => u.id === selectedUserId) || null;
  }, [users, selectedUserId]);

  const getCourse = (courseId: number) => {
    return courses.find((c) => c.id === courseId) || null;
  };

  // Filtered Entitlements
  const filteredEntitlements = useMemo(() => {
    if (!courseSearch.trim()) return entitlements;
    const query = courseSearch.toLowerCase();
    return entitlements.filter((e) => {
      const course = getCourse(e.course_id);
      const titleMatch = (course?.title || '').toLowerCase().includes(query);
      const idMatch = String(e.course_id).includes(query);
      return titleMatch || idMatch;
    });
  }, [entitlements, courseSearch, courses]);

  // --------------------------------------------------------------------------
  // GRANT COURSE ACCESS
  // --------------------------------------------------------------------------
  const openGrantModal = () => {
    setGrantUserId(selectedUserId || (users.length > 0 ? users[0].id : null));
    setGrantCourseId(courses.length > 0 ? courses[0].id : null);
    setIsGrantOpen(true);
  };

  const handleGrantSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!grantUserId || !grantCourseId) return;

    // Check duplicate active access
    if (grantUserId === selectedUserId) {
      const existing = entitlements.find(
        (e) => e.course_id === grantCourseId && e.status === 'ACTIVE'
      );
      if (existing) {
        toast.info('Already Enrolled', 'This learner already has active access to this course.');
        setIsGrantOpen(false);
        return;
      }
    }

    setGrantSubmitting(true);
    try {
      const targetUser = users.find((u) => u.id === grantUserId);
      const targetCourse = courses.find((c) => c.id === grantCourseId);

      await grantCourseEntitlement(grantUserId, grantCourseId, 'MANUAL_ADMIN_GRANT');
      toast.success(
        'Access Granted',
        `Granted "${targetCourse?.title || 'Course'}" to ${targetUser?.email}.`
      );

      setIsGrantOpen(false);
      if (grantUserId === selectedUserId) {
        await loadUserEntitlements(grantUserId);
      }
    } catch (err: any) {
      toast.error('Grant Failed', err?.message);
    } finally {
      setGrantSubmitting(false);
    }
  };

  // --------------------------------------------------------------------------
  // REVOKE COURSE ACCESS
  // --------------------------------------------------------------------------
  const handleRevokeSubmit = async () => {
    if (!selectedUserId || !revokingItem) return;

    setRevokeSubmitting(true);
    try {
      await revokeCourseEntitlement(selectedUserId, revokingItem.course_id);
      toast.success('Access Revoked', 'Course access removed for learner.');
      setRevokingItem(null);
      await loadUserEntitlements(selectedUserId);
    } catch (err: any) {
      toast.error('Revocation Failed', err?.message);
    } finally {
      setRevokeSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <PageHeader
        title="Course Entitlements Studio"
        subtitle="Authorize, inspect, and revoke manual or purchased course entitlements for learners"
        breadcrumbs={[{ label: 'Admin', href: '/' }, { label: 'Entitlements' }]}
        action={
          <div className="flex items-center gap-2.5">
            <button
              onClick={() => selectedUserId && loadUserEntitlements(selectedUserId)}
              className="p-2 bg-white hover:bg-slate-50 border border-slate-200 rounded-lg text-slate-600 hover:text-slate-900 transition-colors shadow-2xs cursor-pointer"
              title="Refresh Entitlements"
            >
              <RefreshCw size={15} />
            </button>
            <Button onClick={openGrantModal} leftIcon={<Plus size={16} />}>
              Grant Course Access
            </Button>
          </div>
        }
      />

      {/* Main Workspace: Left User Selector + Right Entitlements View */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: Learner Selector (4 cols) */}
        <div className="lg:col-span-4 space-y-4">
          <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-500">
                Select Learner
              </span>
              <span className="text-xs text-slate-400">{users.length} accounts</span>
            </div>

            {loadingUsers ? (
              <TableSkeleton rows={4} />
            ) : (
              <div className="space-y-2 max-h-[520px] overflow-y-auto pr-1">
                {users.map((user) => {
                  const isSelected = user.id === selectedUserId;
                  return (
                    <button
                      key={user.id}
                      onClick={() => handleUserChange(user.id)}
                      className={`w-full p-3 rounded-xl border text-left transition-all flex items-center gap-3 cursor-pointer ${
                        isSelected
                          ? 'bg-indigo-50/70 border-indigo-300 ring-2 ring-indigo-500/20'
                          : 'bg-white hover:bg-slate-50 border-slate-200'
                      }`}
                    >
                      <div className="w-10 h-10 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center font-bold text-sm shrink-0">
                        {(user.name || user.email || 'U')[0].toUpperCase()}
                      </div>

                      <div className="min-w-0 flex-1">
                        <p className="font-bold text-slate-900 text-xs truncate">
                          {user.name || 'Unnamed Student'}
                        </p>
                        <p className="text-[11px] text-slate-500 truncate">{user.email}</p>
                        <div className="flex items-center gap-1.5 mt-1">
                          <Badge variant="outline" size="sm" className="text-[10px]">
                            {user.role}
                          </Badge>
                          {user.firebase_uid && (
                            <span className="font-mono text-[10px] text-slate-400 truncate max-w-[90px]">
                              {user.firebase_uid.substring(0, 8)}...
                            </span>
                          )}
                        </div>
                      </div>
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        </div>

        {/* Right Column: Active Entitlements & Course Grants (8 cols) */}
        <div className="lg:col-span-8 space-y-4">
          {/* Selected Learner Overview Banner */}
          {selectedUser && (
            <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <div className="flex items-center gap-3 min-w-0">
                <div className="w-12 h-12 rounded-xl bg-indigo-600 text-white flex items-center justify-center font-bold text-base shrink-0">
                  <GraduationCap size={22} />
                </div>
                <div className="min-w-0">
                  <h3 className="font-bold text-slate-900 text-sm sm:text-base truncate">
                    {selectedUser.name || selectedUser.email}
                  </h3>
                  <p className="text-xs text-slate-500">
                    Account ID: #{selectedUser.id} &bull; {selectedUser.email} &bull;{' '}
                    <span className="capitalize font-medium text-slate-700">{selectedUser.role}</span>
                  </p>
                </div>
              </div>

              <Button size="sm" onClick={openGrantModal} leftIcon={<Plus size={14} />}>
                Enroll in Course
              </Button>
            </div>
          )}

          {/* Search Courses inside Entitlements */}
          <div className="bg-white p-3 rounded-xl border border-slate-200 shadow-2xs">
            <div className="relative">
              <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
              <input
                type="text"
                value={courseSearch}
                onChange={(e) => setCourseSearch(e.target.value)}
                placeholder="Filter enrolled courses by title or ID..."
                className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>

          {/* Entitlements Table */}
          <div className="bg-white rounded-xl border border-slate-200 shadow-2xs overflow-hidden">
            {loadingEntitlements ? (
              <TableSkeleton rows={4} />
            ) : filteredEntitlements.length === 0 ? (
              <EmptyState
                icon={Layers}
                title="No course enrollments"
                description={
                  courseSearch
                    ? 'No courses matched your search query.'
                    : 'This learner has not been granted any course access yet.'
                }
                actionLabel="+ Grant First Course Access"
                onAction={openGrantModal}
              />
            ) : (
              <div className="divide-y divide-slate-100">
                {filteredEntitlements.map((item) => {
                  const course = getCourse(item.course_id);
                  const isRevoked = item.status === 'REVOKED';

                  return (
                    <div
                      key={item.id}
                      className={`p-4 sm:px-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50/75 transition-colors ${
                        isRevoked ? 'opacity-60 bg-slate-50/30' : ''
                      }`}
                    >
                      {/* Left: Course Title & Thumbnail */}
                      <div className="flex items-center gap-3.5 min-w-0">
                        {course?.thumbnail ? (
                          <img
                            src={course.thumbnail}
                            alt=""
                            className="w-14 h-10 rounded-lg object-cover border border-slate-200 shrink-0"
                          />
                        ) : (
                          <div className="w-14 h-10 rounded-lg bg-slate-900 text-indigo-400 flex items-center justify-center font-bold text-xs shrink-0">
                            <BookOpen size={16} />
                          </div>
                        )}

                        <div className="min-w-0">
                          <p className="font-bold text-slate-900 text-xs sm:text-sm truncate">
                            {course?.title || `Course #${item.course_id}`}
                          </p>
                          <div className="flex items-center gap-2 text-[11px] text-slate-500 mt-1 flex-wrap">
                            <span className="font-mono">Course #{item.course_id}</span>
                            <span>&bull;</span>
                            <span>Source: {item.order_id || 'Manual Admin Grant'}</span>
                            {item.granted_at && (
                              <>
                                <span>&bull;</span>
                                <span>Granted {formatDate(item.granted_at)}</span>
                              </>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* Right: Status Badge & Revoke Button */}
                      <div className="flex items-center gap-3 shrink-0 justify-between sm:justify-end">
                        <Badge
                          variant={item.status === 'ACTIVE' ? 'success' : 'danger'}
                          size="sm"
                          className="gap-1 font-bold text-[11px]"
                        >
                          {item.status === 'ACTIVE' ? <CheckCircle2 size={11} /> : <AlertCircle size={11} />}
                          <span>{item.status}</span>
                        </Badge>

                        {item.status === 'ACTIVE' && (
                          <button
                            onClick={() => setRevokingItem(item)}
                            className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors cursor-pointer"
                            title="Revoke Course Access"
                          >
                            <Trash2 size={15} />
                          </button>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ── 1. GRANT COURSE ACCESS MODAL ──────────────────────────────────── */}
      <Modal
        isOpen={isGrantOpen}
        onClose={() => setIsGrantOpen(false)}
        title="Grant Course Access"
        subtitle="Manually grant tutorial access to an active student account"
        maxWidth="md"
      >
        <form onSubmit={handleGrantSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">Target Learner *</label>
            <select
              value={grantUserId || ''}
              onChange={(e) => setGrantUserId(Number(e.target.value))}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              required
            >
              {users.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.name ? `${u.name} (${u.email})` : u.email} — {u.role}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">Target Course *</label>
            <select
              value={grantCourseId || ''}
              onChange={(e) => setGrantCourseId(Number(e.target.value))}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              required
            >
              {courses.map((c) => (
                <option key={c.id} value={c.id}>
                  #{c.id} - {c.title} ({c.is_published ? 'Published' : 'Draft'})
                </option>
              ))}
            </select>
          </div>

          <div className="flex justify-end gap-3 pt-3 border-t border-slate-100">
            <Button type="button" variant="secondary" onClick={() => setIsGrantOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={!grantUserId || !grantCourseId} isLoading={grantSubmitting}>
              Confirm Grant
            </Button>
          </div>
        </form>
      </Modal>

      {/* ── 2. REVOKE COURSE ACCESS CONFIRMATION MODAL ────────────────────── */}
      <Modal
        isOpen={!!revokingItem}
        onClose={() => setRevokingItem(null)}
        title="Revoke Course Access"
        subtitle="Lock course lessons for this student"
        maxWidth="md"
      >
        <div className="space-y-4 text-xs sm:text-sm text-slate-600">
          <div className="p-3.5 bg-rose-50 border border-rose-200 rounded-xl text-rose-800 text-xs flex items-start gap-2.5">
            <AlertTriangle size={18} className="text-rose-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Immediate Access Lock</p>
              <p className="mt-0.5">
                Are you sure you want to revoke access to{' '}
                <strong>"{revokingItem ? getCourse(revokingItem.course_id)?.title : ''}"</strong> for{' '}
                {selectedUser?.email}? The student will immediately be blocked from paid video lessons.
              </p>
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setRevokingItem(null)}>
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
