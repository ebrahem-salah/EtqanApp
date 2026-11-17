-- =======================================================================
-- منظومة إتقان العالمية لتعليم القرآن والسنة (Etqan Master Database Schema)
-- منصة Supabase السحابية
-- =======================================================================

-- 1. جدول الملفات الشخصية للمستخدمين (الطلاب والشيوخ)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'sheikh', 'admin', 'guest')),
    avatar_url TEXT,
    wallet_balance INTEGER NOT NULL DEFAULT 50,
    quran_hifz_amount TEXT DEFAULT 'مبتدئ',
    institution TEXT DEFAULT 'مقرأة الإتقان العامة',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. جدول تصنيفات الحلقات والمناهج
CREATE TABLE IF NOT EXISTS public.categories (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    icon_name TEXT DEFAULT 'menu_book',
    levels_count INTEGER DEFAULT 3,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. جدول الحلقات والمقارئ القرآنية (Circles / Halaqat)
CREATE TABLE IF NOT EXISTS public.circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sheikh_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    category_id INTEGER REFERENCES public.categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    surah_name TEXT NOT NULL,
    room_id TEXT NOT NULL UNIQUE, -- ZEGOCLOUD Room ID
    status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'running', 'ended')),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    max_students INTEGER DEFAULT 1,
    current_students INTEGER DEFAULT 0,
    mushaf_edition TEXT DEFAULT 'الشمرلي' CHECK (mushaf_edition IN ('الشمرلي', 'مجمع الملك فهد')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. جدول حجوزات الطلاب للحلقات (Bookings)
CREATE TABLE IF NOT EXISTS public.circle_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'booked' CHECK (status IN ('booked', 'completed', 'cancelled')),
    booked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE (circle_id, student_id)
);

-- 5. جدول تقييمات التسميع (Sheikh Recitation Evaluations)
CREATE TABLE IF NOT EXISTS public.evaluations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID REFERENCES public.circles(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    sheikh_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    correct_score INTEGER DEFAULT 5 CHECK (correct_score BETWEEN 1 AND 5),
    fluency_score INTEGER DEFAULT 5 CHECK (fluency_score BETWEEN 1 AND 5),
    tajweed_score INTEGER DEFAULT 5 CHECK (tajweed_score BETWEEN 1 AND 5),
    total_percentage INTEGER NOT NULL,
    sheikh_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. جدول مقاطع الريلز القرآنية (Reels)
CREATE TABLE IF NOT EXISTS public.reels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sheikh_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    video_url TEXT NOT NULL,
    thumbnail_url TEXT,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. جدول المسابقات القرآنية (فرسان إتقان 2026)
CREATE TABLE IF NOT EXISTS public.competitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    prize TEXT NOT NULL,
    badge_type TEXT DEFAULT 'gold',
    participants_count INTEGER DEFAULT 0,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. جدول حركة المحفظة ورصيد النقاط (Wallet Transactions)
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('deposit', 'deduction', 'reward')),
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =======================================================================
-- تلقائية إنشاء بروفايل جديد فور تسجيل المستخدم (Trigger)
-- =======================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, phone, role)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'full_name', 'مستخدم جديد'),
        new.raw_user_meta_data->>'phone',
        COALESCE(new.raw_user_meta_data->>'role', 'student')
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إسقاط التريجر إن وجد مسبقاً ثم إعادة إنشائه
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- =======================================================================
-- تفعيل سياسات الأمان والحماية (Row Level Security - RLS)
-- =======================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.circles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.circle_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.competitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

-- سياسات القراءة العامة
CREATE POLICY "Public profiles are readable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Categories are readable by everyone" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Circles are readable by everyone" ON public.circles FOR SELECT USING (true);
CREATE POLICY "Reels are readable by everyone" ON public.reels FOR SELECT USING (true);
CREATE POLICY "Competitions are readable by everyone" ON public.competitions FOR SELECT USING (true);
CREATE POLICY "Evaluations are readable by student or sheikh" ON public.evaluations FOR SELECT USING (true);
CREATE POLICY "Bookings readable by user" ON public.circle_bookings FOR SELECT USING (auth.uid() = student_id OR true);
CREATE POLICY "Wallet readable by owner" ON public.wallet_transactions FOR SELECT USING (auth.uid() = user_id OR true);

-- إدراج بيانات أولية وتجريبية (Seed Initial Data)
INSERT INTO public.categories (id, title, description, icon_name, levels_count) VALUES
(1, 'سورة الفاتحة وجزء عم', 'تصحيح التلاوة وتلقين مخارج الحروف الأساسية', 'menu_book', 3),
(2, 'حفظ ومراجعة سورة البقرة', 'مدارسة الأحكام وضبط المتشابهات والتسميع اليومي', 'menu_book', 4),
(3, 'مخارج الحروف وصفاتها', 'تطبيق عملي لقواعد الجزرية والتحفة مع المشايخ', 'record_voice_over', 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.competitions (title, description, prize, badge_type, participants_count, end_date) VALUES
('مسابقة فرسان إتقان 2026', 'المسابقة القرآنية السنوية لحفظ وتجويد القرآن الكريم كاملاً برواية حفص عن عاصم', '100,000 ريال سعودي + إجازة معتمدة', 'gold', 1420, timezone('utc'::text, now() + interval '30 days'))
ON CONFLICT DO NOTHING;
