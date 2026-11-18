-- =======================================================================
-- منظومة إتقان العالمية لتعليم القرآن والسنة (Etqan Master Database Schema)
-- منصة Supabase السحابية (مطابقة 100% لتطبيق إتقان الفعلي)
-- =======================================================================

-- 1. جدول الملفات الشخصية للمستخدمين (الطلاب والشيوخ)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'sheikh', 'admin', 'volunteer')),
    title TEXT DEFAULT 'طالب علم', -- إمام مسجد / مقرئ / متطوع
    is_volunteer BOOLEAN DEFAULT false,
    avatar_url TEXT,
    wallet_balance INTEGER NOT NULL DEFAULT 50,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. جدول تصنيفات الحلقات والمناهج (الـ 11 تصنيفاً الأصلية)
CREATE TABLE IF NOT EXISTS public.categories (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL UNIQUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    has_levels BOOLEAN DEFAULT false,
    icon_name TEXT DEFAULT 'menu_book',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. جدول الأقسام الفرعية والمستويات والمقررات (Subcategories / Courses)
CREATE TABLE IF NOT EXISTS public.subcategories (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES public.categories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT, -- المستوى الأول / المستوى الثاني
    image_url TEXT,
    badge_number INTEGER, -- 1, 2, 3 للقاعدة النورانية
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. جدول الحلقات المباشرة والمقارئ (Halaqat & Circles)
CREATE TABLE IF NOT EXISTS public.circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sheikh_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    category_id INTEGER REFERENCES public.categories(id) ON DELETE SET NULL,
    subcategory_id INTEGER REFERENCES public.subcategories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    surah_name TEXT NOT NULL DEFAULT 'سورة الفاتحة',
    room_id TEXT NOT NULL UNIQUE, -- ZEGOCLOUD Room ID
    status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'running', 'ended')),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    mushaf_edition TEXT DEFAULT 'الشمرلي' CHECK (mushaf_edition IN ('الشمرلي', 'مجمع الملك فهد')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. جدول مقاطع الريلز والفيديوهات التعليمية (Reels)
CREATE TABLE IF NOT EXISTS public.reels (
    id SERIAL PRIMARY KEY,
    user_name TEXT NOT NULL,
    user_role TEXT DEFAULT 'إمام مسجد',
    is_volunteer BOOLEAN DEFAULT true,
    time_ago TEXT DEFAULT 'منذ 7 شهر',
    avatar_url TEXT,
    caption TEXT NOT NULL,
    video_url TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. جدول تعليقات الريلز (Reel Comments)
CREATE TABLE IF NOT EXISTS public.reel_comments (
    id SERIAL PRIMARY KEY,
    reel_id INTEGER REFERENCES public.reels(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. جدول المسابقات والجوائز (Competitions)
CREATE TABLE IF NOT EXISTS public.competitions (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    prize_amount TEXT NOT NULL,
    participants_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    ends_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. جدول تقييمات الشيوخ للتسميع (Recitation Evaluations)
CREATE TABLE IF NOT EXISTS public.evaluations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID REFERENCES public.circles(id) ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    sheikh_name TEXT NOT NULL,
    correct_score INTEGER DEFAULT 25,
    fluency_score INTEGER DEFAULT 25,
    tajweed_score INTEGER DEFAULT 25,
    stops_score INTEGER DEFAULT 25,
    total_percentage INTEGER NOT NULL,
    grade_tier TEXT NOT NULL DEFAULT 'ممتاز',
    certificate_code TEXT UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =======================================================================
-- البيانات الأولية المطابقة للصور الأصلية (SEED DATA)
-- =======================================================================

-- 1. إضافة الأقسام الرئيسية الـ 11
INSERT INTO public.categories (id, title, sort_order, has_levels) VALUES
(1, 'تعليم الحروف والقاعدة النورانية', 1, true),
(2, 'القرآن الكريم', 2, false),
(3, 'مقرأة إهداء الثواب', 3, false),
(4, 'السنة النبوية', 4, false),
(5, 'علوم أخرى', 5, false),
(6, 'الفتاوى', 6, false),
(7, 'الرقية الشرعية', 7, false),
(8, 'الطفل المسلم', 8, false),
(9, 'المرأة المسلمة', 9, false),
(10, 'قسم الفقه', 10, false),
(11, 'قسم الابتهال', 11, false)
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;

-- 2. إضافة الأقسام الفرعية والمستويات لكل تصنيف

-- أ) تعليم الحروف والقاعدة النورانية (الصور 3 و 4 و 5)
INSERT INTO public.subcategories (category_id, title, subtitle, badge_number, sort_order) VALUES
(1, 'القسم الاول', 'المستوى الأول', 1, 1),
(1, 'القسم الثاني', 'المستوى الثاني', 2, 2),
(1, 'القسم الثالث', 'المستوى الثالث', 3, 3);

-- ب) القرآن الكريم (الصور 6 و 7)
INSERT INTO public.subcategories (category_id, title, sort_order, image_url) VALUES
(2, 'الحفظ', 1, 'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=300'),
(2, 'المراجعة', 2, 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=300'),
(2, 'التجويد', 3, 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=300'),
(2, 'المدارسة', 4, 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=300'),
(2, 'المقرأة', 5, 'https://images.unsplash.com/photo-1590076215667-875d4ef2d7ee?w=300'),
(2, 'علوم القرآن', 6, 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=300'),
(2, 'القراءات العشر', 7, 'https://images.unsplash.com/photo-1519817650390-64a93db51149?w=300'),
(2, 'المقامات الصوتية', 8, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300'),
(2, 'التفسير', 9, 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=300'),
(2, 'القراءات', 10, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300');

-- ج) مقرأة إهداء الثواب (الصورة 8)
INSERT INTO public.subcategories (category_id, title, sort_order, image_url) VALUES
(3, 'رجال', 1, 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=300'),
(3, 'نساء', 2, 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=300');

-- د) السنة النبوية (الصورة 9)
INSERT INTO public.subcategories (category_id, title, sort_order, image_url) VALUES
(4, 'الحفظ', 1, 'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=300'),
(4, 'علوم الحديث', 2, 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=300'),
(4, 'شروح الأحاديث', 3, 'https://images.unsplash.com/photo-1519817650390-64a93db51149?w=300'),
(4, 'الإقراء لكتب السنة', 4, 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=300'),
(4, 'القراءة بالإسناد', 5, 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=300');

-- هـ) علوم أخرى (الصورة 10)
INSERT INTO public.subcategories (category_id, title, sort_order, image_url) VALUES
(5, 'الفقه', 1, 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=300'),
(5, 'السيرة', 2, 'https://images.unsplash.com/photo-1519817650390-64a93db51149?w=300'),
(5, 'العقيدة', 3, 'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=300'),
(5, 'الرقائق', 4, 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=300'),
(5, 'تيست', 5, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300');

-- 3. إضافة مقاطع الريلز الأصلية المطابقة للصور 1 و 2
INSERT INTO public.reels (user_name, user_role, is_volunteer, time_ago, avatar_url, caption, video_url, likes_count, comments_count, shares_count) VALUES
('مريم مستخدمت', 'إمام مسجد', true, 'منذ 7 شهر', 'assets/images/profile.png', 'تحفه ما شاء الله', 'assets/videos/onboarding_video_1.mp4', 4, 5, 2),
('Ahmed', 'إمام مسجد', true, 'منذ 21 يوم', 'assets/images/welcome_sheikh_illustration.png', 'اعمل ما تحب', 'assets/videos/onboarding_video_2.mp4', 0, 0, 1),
('د / عبد الله الرويلي', 'مشرف مقرأة', false, 'منذ شهر', 'assets/images/profile.png', 'من اعظم اسباب تجعلك سعيداً في الحياه', 'assets/videos/onboarding_video_1.mp4', 234, 45, 18);

-- =======================================================================
-- 9. جدول حجوزات جلسات التسميع (Circle Bookings)
-- =======================================================================
CREATE TABLE IF NOT EXISTS public.circle_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    sheikh_name TEXT NOT NULL,
    circle_title TEXT NOT NULL,
    booking_date DATE NOT NULL DEFAULT CURRENT_DATE,
    time_slot TEXT NOT NULL, -- مثلاً: 05:00 م - 06:00 م
    status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    room_id TEXT NOT NULL, -- ZEGOCLOUD Room ID
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =======================================================================
-- 10. جدول المعاملات المالية وشحن المحفظة (Wallet Transactions)
-- =======================================================================
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    points_credited INTEGER NOT NULL DEFAULT 0,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('mada', 'visa', 'apple_pay', 'stc_pay', 'fawry', 'points')),
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('recharge', 'booking_fee', 'reward', 'refund')),
    status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
    reference_number TEXT UNIQUE,
    gateway_response JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =======================================================================
-- 11. جدول الإشعارات اللحظية وسجلات التنبيهات (Push Notifications)
-- =======================================================================
CREATE TABLE IF NOT EXISTS public.push_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    notification_type TEXT NOT NULL CHECK (notification_type IN ('circle_live', 'booking_reminder', 'competition', 'wallet', 'general')),
    is_read BOOLEAN DEFAULT false,
    payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =======================================================================
-- بيانات أولية للحجوزات والمحفظة والإشعارات (Seed Data)
-- =======================================================================
INSERT INTO public.circle_bookings (student_name, sheikh_name, circle_title, booking_date, time_slot, status, room_id) VALUES
('أحمد الطالب', 'الشيخ عبد الله السويسي', 'حلقة إتقان التجويد ومخارج الحروف', CURRENT_DATE, '05:00 م - 06:00 م', 'confirmed', 'circle_tajweed_101');

INSERT INTO public.push_notifications (title, body, notification_type, is_read) VALUES
('🕌 حلقة مباشرة الآن', 'الشيخ سعد علي بدأ حلقة تلاوة سورة البقرة الآن. انقر للانضمام.', 'circle_live', false),
('📅 تذكير بموعد الجلسة', 'لديك جلسة تسميع مع الشيخ عبد الله السويسي اليوم الساعة 5:00 مساءً.', 'booking_reminder', false),
('🏆 مسابقات إتقان الكبرى', 'تم فتح باب التسجيل في مسابقة القرآن الكريم السنوية بجوائز 50,000 ريال.', 'competition', true);

