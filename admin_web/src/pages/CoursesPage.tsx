import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  fetchAdminCourses,
  createAdminCourse,
  updateAdminCourse,
  toggleCoursePublish,
  deleteAdminCourse,
} from '../api/courses';
import { Course } from '../types';
import { formatCurrency } from '../utils/format';
import { useToast } from '../context/ToastContext';
import {
  Search,
  Plus,
  Edit2,
  Trash2,
  BookOpen,
  CheckCircle2,
  Clock,
  Layers,
  AlertCircle,
  RefreshCw,
  Sparkles,
} from 'lucide-react';
import { Badge } from '../components/Badge';
import { Modal } from '../components/Modal';
import { Button } from '../components/Button';
import { PageHeader } from '../components/PageHeader';
import { EmptyState } from '../components/EmptyState';
import { TableSkeleton } from '../components/LoadingSkeleton';

export const CoursesPage: React.FC = () => {
  const toast = useToast();
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'published' | 'draft'>('all');
  const [categoryFilter, setCategoryFilter] = useState('all');

  // Modals state
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [editingCourse, setEditingCourse] = useState<Course | null>(null);
  const [deletingCourse, setDeletingCourse] = useState<Course | null>(null);
  const [formSubmitting, setFormSubmitting] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [togglingCourseId, setTogglingCourseId] = useState<number | null>(null);

  // Form State
  const [formData, setFormData] = useState<Partial<Course>>({
    title: '',
    description: '',
    short_description: '',
    thumbnail: '',
    price: 0,
    original_price: 0,
    category: 'Robotics',
    level: 'Beginner',
    instructor: 'Edukkit Team',
    bunny_collection_id: '',
    is_published: false,
    is_free: false,
  });

  const loadCourses = async () => {
    setLoading(true);
    try {
      const data = await fetchAdminCourses({
        status_filter: statusFilter === 'all' ? undefined : statusFilter,
        category: categoryFilter === 'all' ? undefined : categoryFilter,
      });
      setCourses(data);
    } catch (err: any) {
      toast.error('Failed to load courses', err?.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCourses();
  }, [statusFilter, categoryFilter]);

  const openCreateModal = () => {
    setFormData({
      title: '',
      description: '',
      short_description: '',
      thumbnail: '',
      price: 999,
      original_price: 1499,
      category: 'Robotics',
      level: 'Beginner',
      instructor: 'Edukkit Lead Instructor',
      bunny_collection_id: '',
      is_published: false,
      is_free: false,
    });
    setFormError(null);
    setIsCreateOpen(true);
  };

  const openEditModal = (course: Course) => {
    setEditingCourse(course);
    setFormData({
      title: course.title,
      description: course.description || '',
      short_description: course.short_description || '',
      thumbnail: course.thumbnail || '',
      price: course.price,
      original_price: course.original_price || 0,
      category: course.category || 'Robotics',
      level: course.level || 'Beginner',
      instructor: course.instructor || '',
      bunny_collection_id: course.bunny_collection_id || '',
      is_published: course.is_published,
      is_free: course.is_free,
    });
    setFormError(null);
  };

  const handleSaveCourse = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.title?.trim()) {
      setFormError('Course title is required.');
      return;
    }
    if ((formData.price ?? 0) < 0) {
      setFormError('Course price cannot be negative.');
      return;
    }

    setFormSubmitting(true);
    setFormError(null);
    try {
      if (editingCourse) {
        await updateAdminCourse(editingCourse.id, formData);
        toast.success('Course Updated', `"${formData.title}" saved successfully.`);
      } else {
        await createAdminCourse(formData);
        toast.success('Course Created', `"${formData.title}" added to catalog.`);
      }
      setIsCreateOpen(false);
      setEditingCourse(null);
      await loadCourses();
    } catch (err: any) {
      setFormError(err?.message || 'Failed to save course');
      toast.error('Error Saving Course', err?.message);
    } finally {
      setFormSubmitting(false);
    }
  };

  const handleTogglePublish = async (course: Course) => {
    const nextState = !course.is_published;
    setTogglingCourseId(course.id);
    try {
      await toggleCoursePublish(course.id, nextState);
      setCourses((prev) =>
        prev.map((c) => (c.id === course.id ? { ...c, is_published: nextState } : c))
      );
      toast.success(
        nextState ? 'Course Published' : 'Course Set to Draft',
        `"${course.title}" is now ${nextState ? 'live for students' : 'hidden as a draft'}.`
      );
    } catch (err: any) {
      toast.error('Failed to change publish status', err?.message);
    } finally {
      setTogglingCourseId(null);
    }
  };

  const handleDeleteCourse = async () => {
    if (!deletingCourse) return;
    setFormSubmitting(true);
    try {
      await deleteAdminCourse(deletingCourse.id);
      toast.success('Course Deleted', `"${deletingCourse.title}" removed permanently.`);
      setDeletingCourse(null);
      await loadCourses();
    } catch (err: any) {
      toast.error('Deletion Failed', err?.message);
    } finally {
      setFormSubmitting(false);
    }
  };

  const filteredCourses = courses.filter((c) => {
    if (!search) return true;
    const q = search.toLowerCase();
    return (
      c.title.toLowerCase().includes(q) ||
      (c.instructor && c.instructor.toLowerCase().includes(q)) ||
      (c.category && c.category.toLowerCase().includes(q))
    );
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <PageHeader
        title="Course Catalog & Pricing"
        subtitle="Create, configure syllabus pricing, publish courses, and manage curriculum structures"
        breadcrumbs={[{ label: 'Admin', href: '/' }, { label: 'Courses' }]}
        action={
          <div className="flex items-center gap-2.5">
            <button
              onClick={loadCourses}
              className="p-2 bg-white hover:bg-slate-50 border border-slate-200 rounded-lg text-slate-600 hover:text-slate-900 transition-colors shadow-2xs cursor-pointer"
              title="Refresh Course List"
            >
              <RefreshCw size={15} />
            </button>
            <Button onClick={openCreateModal} leftIcon={<Plus size={16} />}>
              New Course
            </Button>
          </div>
        }
      />

      {/* Filter & Search Bar */}
      <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-2xs flex flex-col md:flex-row items-center gap-3">
        <div className="relative flex-1 w-full">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search courses by title, category, or instructor..."
            className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs sm:text-sm focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div className="flex items-center gap-2 w-full md:w-auto">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as any)}
            className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs sm:text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option value="all">All Lifecycle Statuses</option>
            <option value="published">Published Live</option>
            <option value="draft">Drafts Only</option>
          </select>

          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs sm:text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option value="all">All Categories</option>
            <option value="Robotics">Robotics</option>
            <option value="Electronics">Electronics</option>
            <option value="Programming">Programming</option>
            <option value="AI & IoT">AI & IoT</option>
            <option value="Arduino">Arduino</option>
            <option value="STEM Kits">STEM Kits</option>
          </select>
        </div>
      </div>

      {/* Courses Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-2xs overflow-hidden">
        {loading ? (
          <TableSkeleton rows={5} />
        ) : filteredCourses.length === 0 ? (
          <EmptyState
            icon={BookOpen}
            title="No courses found"
            description={
              search
                ? 'Try adjusting your search query or reset the active filter criteria.'
                : 'Get started by creating your first course syllabus.'
            }
            actionLabel={search ? undefined : '+ Create First Course'}
            onAction={search ? undefined : openCreateModal}
          />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 text-[11px] uppercase font-bold tracking-wider">
                  <th className="px-6 py-3.5">Course Info</th>
                  <th className="px-6 py-3.5">Category & Level</th>
                  <th className="px-6 py-3.5">Pricing</th>
                  <th className="px-6 py-3.5">Curriculum</th>
                  <th className="px-6 py-3.5">Publish Status</th>
                  <th className="px-6 py-3.5 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs sm:text-sm text-slate-700">
                {filteredCourses.map((course) => (
                  <tr key={course.id} className="hover:bg-slate-50/75 transition-colors">
                    {/* Title & Instructor */}
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        {course.thumbnail ? (
                          <img
                            src={course.thumbnail}
                            alt=""
                            className="w-12 h-8 rounded-md object-cover bg-slate-100 border border-slate-200 shrink-0"
                          />
                        ) : (
                          <div className="w-12 h-8 rounded-md bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold text-xs border border-indigo-100 shrink-0">
                            {course.title.substring(0, 2).toUpperCase()}
                          </div>
                        )}
                        <div className="min-w-0">
                          <Link
                            to={`/curriculum?courseId=${course.id}`}
                            className="font-semibold text-slate-900 hover:text-indigo-600 transition-colors line-clamp-1"
                          >
                            {course.title}
                          </Link>
                          <p className="text-xs text-slate-500 line-clamp-1">
                            Instructor: {course.instructor || 'Edukkit Staff'}
                          </p>
                        </div>
                      </div>
                    </td>

                    {/* Category & Level */}
                    <td className="px-6 py-4">
                      <div className="flex flex-col gap-1">
                        <span className="text-xs font-medium text-slate-800">
                          {course.category || 'General'}
                        </span>
                        <Badge variant="outline" size="sm" className="w-fit text-[10px]">
                          {course.level || 'Beginner'}
                        </Badge>
                      </div>
                    </td>

                    {/* Price */}
                    <td className="px-6 py-4">
                      {course.is_free ? (
                        <Badge variant="success" size="sm" className="gap-1 items-center">
                          <Sparkles size={11} />
                          <span>100% Free</span>
                        </Badge>
                      ) : (
                        <div>
                          <div className="font-bold text-slate-900">
                            {formatCurrency(course.price)}
                          </div>
                          {course.original_price && course.original_price > course.price && (
                            <div className="text-xs text-slate-400 line-through">
                              {formatCurrency(course.original_price)}
                            </div>
                          )}
                        </div>
                      )}
                    </td>

                    {/* Lessons Count & Direct Studio Link */}
                    <td className="px-6 py-4">
                      <Link
                        to={`/curriculum?courseId=${course.id}`}
                        className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-indigo-50 text-indigo-700 hover:bg-indigo-100 text-xs font-semibold transition-colors"
                        title="Manage Lessons in Curriculum Studio"
                      >
                        <Layers size={13} />
                        <span>{course.lessons_count || 0} Lessons</span>
                      </Link>
                    </td>

                    {/* Status & Quick Toggle */}
                    <td className="px-6 py-4">
                      <button
                        onClick={() => handleTogglePublish(course)}
                        disabled={togglingCourseId === course.id}
                        className="group flex items-center gap-1.5 focus:outline-none cursor-pointer"
                        title={`Click to ${course.is_published ? 'unpublish' : 'publish'}`}
                      >
                        {course.is_published ? (
                          <Badge variant="success" size="sm" className="gap-1 items-center group-hover:bg-emerald-100">
                            <CheckCircle2 size={12} />
                            <span>Published</span>
                          </Badge>
                        ) : (
                          <Badge variant="warning" size="sm" className="gap-1 items-center group-hover:bg-amber-100">
                            <Clock size={12} />
                            <span>Draft</span>
                          </Badge>
                        )}
                      </button>
                    </td>

                    {/* Actions */}
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        <Link
                          to={`/curriculum?courseId=${course.id}`}
                          className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-md transition-colors"
                          title="Open Curriculum Studio"
                        >
                          <BookOpen size={16} />
                        </Link>
                        <button
                          onClick={() => openEditModal(course)}
                          className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-md transition-colors cursor-pointer"
                          title="Edit Metadata & Pricing"
                        >
                          <Edit2 size={16} />
                        </button>
                        <button
                          onClick={() => setDeletingCourse(course)}
                          className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors cursor-pointer"
                          title="Delete Course"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* CREATE / EDIT COURSE MODAL */}
      <Modal
        isOpen={isCreateOpen || !!editingCourse}
        onClose={() => {
          setIsCreateOpen(false);
          setEditingCourse(null);
        }}
        title={editingCourse ? `Edit Course: ${editingCourse.title}` : 'Create New Course'}
        subtitle="Configure course information, pricing, and Bunny collection metadata"
        maxWidth="2xl"
      >
        <form onSubmit={handleSaveCourse} className="space-y-4">
          {formError && (
            <div className="p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-lg text-xs flex items-center gap-2">
              <AlertCircle size={14} className="shrink-0" />
              <span>{formError}</span>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Course Title *
            </label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              placeholder="e.g. Arduino Robotics 101"
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              required
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">Category</label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              >
                <option value="Robotics">Robotics</option>
                <option value="Electronics">Electronics</option>
                <option value="Programming">Programming</option>
                <option value="AI & IoT">AI & IoT</option>
                <option value="Arduino">Arduino</option>
                <option value="STEM Kits">STEM Kits</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Difficulty Level
              </label>
              <select
                value={formData.level}
                onChange={(e) => setFormData({ ...formData, level: e.target.value })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              >
                <option value="Beginner">Beginner</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Advanced">Advanced</option>
                <option value="All Levels">All Levels</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">Price (₹)</label>
              <input
                type="number"
                step="0.01"
                min="0"
                value={formData.price}
                onChange={(e) =>
                  setFormData({ ...formData, price: parseFloat(e.target.value) || 0 })
                }
                disabled={formData.is_free}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none disabled:bg-slate-100"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Original Price (₹)
              </label>
              <input
                type="number"
                step="0.01"
                min="0"
                value={formData.original_price || 0}
                onChange={(e) =>
                  setFormData({ ...formData, original_price: parseFloat(e.target.value) || 0 })
                }
                disabled={formData.is_free}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none disabled:bg-slate-100"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Instructor Name
              </label>
              <input
                type="text"
                value={formData.instructor}
                onChange={(e) => setFormData({ ...formData, instructor: e.target.value })}
                placeholder="Edukkit Lead Instructor"
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">Thumbnail URL</label>
            <input
              type="url"
              value={formData.thumbnail || ''}
              onChange={(e) => setFormData({ ...formData, thumbnail: e.target.value })}
              placeholder="https://images.unsplash.com/..."
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Short Description
            </label>
            <input
              type="text"
              value={formData.short_description || ''}
              onChange={(e) => setFormData({ ...formData, short_description: e.target.value })}
              placeholder="A brief 1-line overview of the course"
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Full Description
            </label>
            <textarea
              rows={3}
              value={formData.description || ''}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="Detailed syllabus, prerequisites, and learning outcomes"
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2 border-t border-slate-100">
            <label className="flex items-center gap-2 cursor-pointer text-sm font-medium text-slate-700">
              <input
                type="checkbox"
                checked={formData.is_published}
                onChange={(e) => setFormData({ ...formData, is_published: e.target.checked })}
                className="w-4 h-4 text-indigo-600 rounded-sm border-slate-300 focus:ring-indigo-500"
              />
              <span>Publish Course (Live in Mobile App)</span>
            </label>

            <label className="flex items-center gap-2 cursor-pointer text-sm font-medium text-slate-700">
              <input
                type="checkbox"
                checked={formData.is_free}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    is_free: e.target.checked,
                    price: e.target.checked ? 0 : formData.price,
                  })
                }
                className="w-4 h-4 text-indigo-600 rounded-sm border-slate-300 focus:ring-indigo-500"
              />
              <span>100% Free Course (No Checkout Required)</span>
            </label>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
            <Button
              type="button"
              variant="secondary"
              onClick={() => {
                setIsCreateOpen(false);
                setEditingCourse(null);
              }}
            >
              Cancel
            </Button>
            <Button type="submit" isLoading={formSubmitting}>
              {editingCourse ? 'Save Changes' : 'Create Course'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* DELETE CONFIRMATION MODAL */}
      <Modal
        isOpen={!!deletingCourse}
        onClose={() => setDeletingCourse(null)}
        title="Confirm Course Deletion"
        subtitle="This action will permanently delete this course and all associated lessons"
        maxWidth="md"
      >
        <div className="space-y-4">
          <div className="p-3 bg-rose-50 border border-rose-200 rounded-lg text-xs text-rose-800 flex items-start gap-2">
            <AlertCircle size={16} className="text-rose-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Permanent Deletion Warning</p>
              <p className="mt-0.5">
                Deleting <strong>"{deletingCourse?.title}"</strong> will permanently erase its
                database entry and cascade delete all {deletingCourse?.lessons_count || 0} associated
                lessons.
              </p>
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <Button type="button" variant="secondary" onClick={() => setDeletingCourse(null)}>
              Cancel
            </Button>
            <Button
              type="button"
              variant="danger"
              isLoading={formSubmitting}
              onClick={handleDeleteCourse}
            >
              Delete Permanently
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};
