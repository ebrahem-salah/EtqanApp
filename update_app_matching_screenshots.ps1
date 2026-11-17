# PowerShell script to update preview.html and index.html to match user's uploaded screenshots 100%
$filePath = "C:\Users\ESALAH30\.gemini\antigravity\scratch\etqan_flutter_project\preview.html"
$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# 1. New CSS for Reels, FAB, and Chapters
$extraCss = @"
    /* REELS HEADER & TOOLS (Images 1 & 2) */
    .reels-gold-pill {
      background: linear-gradient(135deg, #E2B755 0%, #B78103 100%);
      border-radius: 24px;
      padding: 4px 14px 4px 6px;
      display: flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;
      box-shadow: 0 4px 12px rgba(0,0,0,0.4);
      user-select: none;
    }
    .reels-gold-pill span {
      font-size: 13px;
      font-weight: bold;
      color: #ffffff;
    }
    .reels-gold-coin {
      width: 26px;
      height: 26px;
      border-radius: 50%;
      background: #fff;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 2px 6px rgba(0,0,0,0.3);
    }
    .reels-gold-coin img {
      width: 22px;
      height: 22px;
    }
    .reels-header-tools {
      display: flex;
      align-items: center;
      gap: 10px;
      direction: ltr;
    }
    .reels-tool-btn {
      width: 38px;
      height: 38px;
      border-radius: 50%;
      background: rgba(0, 0, 0, 0.45);
      border: 1px solid rgba(255, 255, 255, 0.25);
      backdrop-filter: blur(6px);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #ffffff;
      font-size: 17px;
      cursor: pointer;
      transition: transform 0.15s ease;
    }
    .reels-tool-btn:active {
      transform: scale(0.9);
    }
    .reels-tool-btn.add-btn {
      border: 1.5px solid #00875A;
      position: relative;
    }
    .reels-tool-btn.add-btn::before {
      content: '';
      position: absolute;
      inset: 2px;
      border-radius: 50%;
      border: 1.5px solid #00875A;
    }
    .reels-avatar-circle {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      background: rgba(255,255,255,0.25);
      border: 2px solid rgba(255,255,255,0.4);
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0,0,0,0.4);
    }
    .reels-badge-volunteer {
      background: #00875A;
      color: #ffffff;
      padding: 2px 8px;
      border-radius: 6px;
      font-size: 11px;
      font-weight: bold;
    }

    /* FLOATING ACTION BUTTON (Images 3 - 10) */
    .etqan-fab {
      position: absolute;
      left: 16px;
      bottom: 78px;
      width: 48px;
      height: 48px;
      border-radius: 50%;
      background: #111111;
      border: 2px solid #00875A;
      box-shadow: 0 4px 14px rgba(0,0,0,0.5), 0 0 0 2px #00875A;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      z-index: 85;
      transition: transform 0.15s ease;
    }
    .etqan-fab:active {
      transform: scale(0.9);
    }
    .etqan-fab-inner {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      border: 1.5px solid #00875A;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #00875A;
      font-size: 26px;
      font-weight: bold;
      line-height: 1;
    }

    /* CHAPTERS LEVELS & GRID CARDS (Images 3 - 10) */
    .subcat-level-card {
      background: #fff;
      border-radius: 12px;
      overflow: hidden;
      margin-bottom: 12px;
      border: 1px solid #e5e5d5;
      cursor: pointer;
      box-shadow: 0 2px 6px rgba(0,0,0,0.04);
      transition: transform 0.15s ease;
    }
    .subcat-level-card:active { transform: scale(0.98); }
    .subcat-level-banner {
      background: radial-gradient(circle, #222 0%, #0d140f 100%);
      height: 94px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      border-radius: 8px 8px 0 0;
      position: relative;
      border: 1px solid #2a3a30;
    }
    .subcat-level-number-badge {
      width: 44px;
      height: 44px;
      background: #00875A;
      color: #fff;
      font-size: 22px;
      font-weight: bold;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 3px 10px rgba(0,135,90,0.45);
      margin-bottom: 4px;
      border: 1px solid #2ecc71;
    }
    .subcat-level-title {
      color: #fff;
      font-size: 13px;
      font-weight: bold;
      letter-spacing: 0.5px;
    }
    .subcat-level-subtitle {
      padding: 8px;
      text-align: center;
      font-size: 12px;
      font-weight: bold;
      color: #222;
      background: #fff;
    }
    .subcat-grid-2col {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 10px;
      padding: 4px;
    }
    .subcat-photo-card {
      background: #fff;
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid #e8e8d8;
      cursor: pointer;
      box-shadow: 0 2px 6px rgba(0,0,0,0.05);
      transition: transform 0.15s ease;
      display: flex;
      flex-direction: column;
    }
    .subcat-photo-card:active { transform: scale(0.97); }
    .subcat-photo-img {
      width: 100%;
      height: 85px;
      object-fit: cover;
      background: #f0f0e0;
    }
    .subcat-photo-title {
      padding: 8px 4px;
      text-align: center;
      font-size: 12px;
      font-weight: bold;
      color: #191919;
    }
"@

if (-not $content.Contains(".reels-gold-pill")) {
    $content = $content.Replace("</style>", "$extraCss`n  </style>")
    Write-Host "Added Extra CSS successfully!"
}

# 2. Update #screen-reels HTML to 100% match Image 1 & 2
$oldReelsScreenRegex = '<!-- SCREEN 2: REELS[\s\S]*?<!-- SCREEN 3: CHAPTERS SCREEN -->'
$newReelsScreen = @"
<!-- SCREEN 2: REELS SCREEN (100% Exact Match with Image 1 & 2) -->
        <div id="screen-reels" class="app-screen active" onclick="toggleReelPlayPause(event)" onwheel="handleReelWheel(event)">
          <video class="reels-video-container" autoplay loop muted playsinline id="reels-video">
            <source src="assets/videos/onboarding_video_1.mp4" type="video/mp4">
          </video>
          <div class="reels-overlay-gradient"></div>

          <!-- Central Play/Pause Tap Area -->
          <div style="position: absolute; inset: 70px 0 110px 0; z-index: 20; display: flex; align-items: center; justify-content: center; cursor: pointer;">
            <div id="reel-play-indicator" style="width: 72px; height: 72px; border-radius: 50%; background: rgba(0,0,0,0.5); backdrop-filter: blur(6px); display: none; align-items: center; justify-content: center; border: 2px solid rgba(255,255,255,0.4);">
              <svg viewBox="0 0 24 24" width="40" height="40" fill="#ffffff"><path d="M8 5v14l11-7z"/></svg>
            </div>
          </div>

          <!-- Top Bar (Matching Image 1 & 2: Right Gold Pill [< المسابقات], Left 3 Circles [Bell, Search, +]) -->
          <div class="reels-header-top">
            <!-- Right: Gold Competitions Button (< المسابقات) -->
            <div class="reels-gold-pill" onclick="openScreen('competitions'); event.stopPropagation();">
              <div class="reels-gold-coin">
                <img src="assets/images/badg_gold.png" alt="Gold Badge">
              </div>
              <span>المسابقات &gt;</span>
            </div>

            <!-- Left: 3 Circular Buttons (Bell, Search, Double-Ring Add) -->
            <div class="reels-header-tools" onclick="event.stopPropagation();">
              <!-- Bell -->
              <div class="reels-tool-btn" onclick="alert('🔔 لا توجد إشعارات جديدة حالياً')">
                <svg viewBox="0 0 24 24" width="20" height="20" stroke="#fff" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
              </div>
              <!-- Search -->
              <div class="reels-tool-btn" onclick="alert('🔍 البحث في مقاطع التلاوة والريلز')">
                <svg viewBox="0 0 24 24" width="18" height="18" stroke="#fff" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
              </div>
              <!-- Double-ring Add Button -->
              <div class="reels-tool-btn add-btn" onclick="showAddOptionsModal()">
                <span style="color: #00875A; font-size: 20px; font-weight: bold; line-height: 1; margin-top: -2px;">+</span>
              </div>
            </div>
          </div>

          <!-- Left Floating Action Controls (Heart, Comment, Expand, Share) -->
          <div class="reels-actions-bar" onclick="event.stopPropagation();">
            <!-- 1. Like -->
            <div class="reels-action-item" id="reel-like-item" onclick="toggleLikeCurrentReel()">
              <div class="reels-action-icon">
                <svg id="reel-like-svg" viewBox="0 0 24 24">
                  <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                </svg>
              </div>
              <span class="action-label" id="reel-likes-num">4</span>
            </div>

            <!-- 2. Comment -->
            <div class="reels-action-item" onclick="openReelCommentsSheet()">
              <div class="reels-action-icon">
                <svg viewBox="0 0 24 24">
                  <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/>
                </svg>
              </div>
              <span class="action-label" id="reel-comments-num">5</span>
            </div>

            <!-- 3. Expand / Fullscreen -->
            <div class="reels-action-item" onclick="toggleFullscreenReel()">
              <div class="reels-action-icon">
                <svg viewBox="0 0 24 24" stroke="#fff" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"></path>
                </svg>
              </div>
            </div>

            <!-- 4. Share -->
            <div class="reels-action-item" onclick="shareCurrentReel()">
              <div class="reels-action-icon">
                <svg viewBox="0 0 24 24" stroke="#fff" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="22" y1="2" x2="11" y2="13"></line>
                  <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                </svg>
              </div>
            </div>
          </div>

          <!-- Bottom Sheikh Info (Matching Image 1 & 2) -->
          <div class="reels-sheikh-info">
            <div style="display: flex; align-items: center; gap: 10px;">
              <div class="reels-avatar-circle" id="reel-avatar-container">
                <img id="reel-avatar-img" src="assets/images/profile.png" alt="Avatar" style="width: 100%; height: 100%; object-fit: cover;">
              </div>
              <div>
                <div style="display: flex; align-items: center; gap: 8px;">
                  <strong id="reel-sheikh-name" style="color: #fff; font-size: 15px; text-shadow: 0 1px 4px rgba(0,0,0,0.9);">مريم مستخدمت</strong>
                  <span class="reels-badge-volunteer" id="reel-volunteer-badge">متطوع</span>
                  <span id="reel-sheikh-role" style="font-size: 12px; color: rgba(255,255,255,0.85); text-shadow: 0 1px 3px rgba(0,0,0,0.8);">إمام مسجد</span>
                </div>
                <div id="reel-time-text" style="font-size: 11px; color: rgba(255,255,255,0.65); margin-top: 2px;">منذ 7 شهر</div>
              </div>
            </div>
            <div class="reels-caption-text" id="reel-caption-text">تحفه ما شاء الله</div>
          </div>

          <!-- Subtle Up/Down Vertical Swipe Arrows on edge -->
          <div style="position: absolute; left: 8px; top: 50%; transform: translateY(-50%); display: flex; flex-direction: column; gap: 8px; z-index: 25; opacity: 0.35;">
            <div onclick="prevReel(); event.stopPropagation();" style="width: 26px; height: 26px; border-radius: 50%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; cursor: pointer; color: #fff; font-size: 11px;" title="المقطع السابق">▲</div>
            <div onclick="nextReel(); event.stopPropagation();" style="width: 26px; height: 26px; border-radius: 50%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; cursor: pointer; color: #fff; font-size: 11px;" title="المقطع التالي">▼</div>
          </div>
        </div>

        <!-- SCREEN 3: CHAPTERS SCREEN -->
"@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldReelsScreenRegex, $newReelsScreen)
Write-Host "Updated Reels Screen HTML!"

# 3. Update Chapters Screen (Images 3 - 10)
$oldChaptersScreenRegex = '<!-- SCREEN 3: CHAPTERS SCREEN -->[\s\S]*?<!-- SCREEN 4: SHEIKHS SCREEN -->'
$newChaptersScreen = @"
<!-- SCREEN 3: CHAPTERS SCREEN (Matching Images 3 - 10 Exactly) -->
        <div id="screen-chapters" class="app-screen">
          <!-- Top Bar -->
          <div style="background: #fff; padding: 12px 18px; border-bottom: 1px solid #eaeae0; display: flex; justify-content: space-between; align-items: center;">
            <div style="width: 36px; height: 36px; border-radius: 50%; background: #fff; border: 1px solid #e0e0d0; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 6px rgba(0,0,0,0.05); cursor: pointer;" onclick="alert('🔔 لا توجد إشعارات جديدة')">
              <svg viewBox="0 0 24 24" width="18" height="18" stroke="#333" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
            </div>
            <h3 style="font-size: 20px; font-weight: bold; color: #191919;">الحلقات</h3>
          </div>

          <div class="chapters-main-layout">
            <!-- Left Subcategories Grid / Level Cards -->
            <div class="subcat-rail-content" id="subcat-box">
              <!-- Dynamically populated by switchCategory -->
            </div>

            <!-- Right Categories Rail (Exact 11 categories from Images 3 - 10) -->
            <div class="cat-rail">
              <!-- Black Library Button at Top (Image 3 - 10) -->
              <div class="cat-rail-btn library-btn" onclick="openScreen('library')">
                <img src="assets/svgs/icon_library.svg" alt="Library" style="width: 16px; filter: brightness(0) invert(1);">
                <span>المكتبة &gt;</span>
              </div>
              <div class="cat-rail-btn active" onclick="switchCategory(this, 'القاعدة النورانية')">تعليم الحروف والقاعدة النورانية</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'القرآن الكريم')">القرآن الكريم</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'مقرأة إهداء الثواب')">مقرأة إهداء الثواب</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'السنة النبوية')">السنة النبوية</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'علوم أخرى')">علوم أخرى</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'الفتاوى')">الفتاوى</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'الرقية الشرعية')">الرقية الشرعية</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'الطفل المسلم')">الطفل المسلم</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'المرأة المسلمة')">المرأة المسلمة</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'قسم الفقه')">قسم الفقه</div>
              <div class="cat-rail-btn" onclick="switchCategory(this, 'قسم الابتهال')">قسم الابتهال</div>
            </div>
          </div>
        </div>

        <!-- SCREEN 4: SHEIKHS SCREEN -->
"@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldChaptersScreenRegex, $newChaptersScreen)
Write-Host "Updated Chapters Screen HTML!"

# 4. Update Bottom Nav and add Floating Action Button
$oldNavRegex = '<!-- Bottom Nav Bar[\s\S]*?</div>\s*</div>\s*</div>'
$newNav = @"
      <!-- Bottom Nav Bar (Exact Match with Images 1 - 10: 5 Tabs) -->
      <div class="app-bottom-nav">
        <button class="nav-tab-item active" id="bnav-reels" onclick="openScreen('reels')">
          <img src="assets/svgs/home.svg" alt="Home">
          <span>الرئيسة</span>
        </button>
        <button class="nav-tab-item" id="bnav-chapters" onclick="openScreen('chapters')">
          <img src="assets/svgs/chapters_tab_icon.svg" alt="Chapters">
          <span>الحلقات</span>
        </button>
        <button class="nav-tab-item" id="bnav-sheikhs" onclick="openScreen('sheikhs')">
          <img src="assets/svgs/supervisors.svg" alt="Sheikhs">
          <span>الشيوخ</span>
        </button>
        <button class="nav-tab-item" id="bnav-mychapters" onclick="openScreen('mychapters')">
          <img src="assets/svgs/video_call.svg" alt="My Chapters">
          <span>حلقاتي</span>
        </button>
        <button class="nav-tab-item" id="bnav-more" onclick="openScreen('more')">
          <img src="assets/svgs/more.svg" alt="More">
          <span>المزيد</span>
        </button>
      </div>

      <!-- Floating Action Button (Exact Match with Images 3 - 10: Circular Double-Ring Button at Bottom Left) -->
      <div class="etqan-fab" onclick="showAddOptionsModal()" title="إضافة حلقة أو مقطع فيديو">
        <div class="etqan-fab-inner">+</div>
      </div>

    </div>
  </div>
"@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldNavRegex, $newNav)
Write-Host "Updated Bottom Nav and added FAB!"

# 5. Update JavaScript reelsList and switchCategory
$oldJsRegex = 'const reelsList = \[[\s\S]*?function switchCategory\(el, catName\) \{[\s\S]*?function openCallWithTitle'
$newJs = @"
const reelsList = [
      {
        userName: 'مريم مستخدمت',
        userRole: 'إمام مسجد',
        isVolunteer: true,
        timeAgo: 'منذ 7 شهر',
        avatar: 'assets/images/profile.png',
        caption: 'تحفه ما شاء الله',
        likes: 4,
        comments: 5,
        shares: 2,
        isLiked: false,
        video: 'assets/videos/onboarding_video_1.mp4'
      },
      {
        userName: 'Ahmed',
        userRole: 'إمام مسجد',
        isVolunteer: true,
        timeAgo: 'منذ 21 يوم',
        avatar: 'assets/images/welcome_sheikh_illustration.png',
        caption: 'اعمل ما تحب',
        likes: 0,
        comments: 0,
        shares: 1,
        isLiked: false,
        video: 'assets/videos/onboarding_video_2.mp4'
      },
      {
        userName: 'د / عبد الله الرويلي',
        userRole: 'مشرف مقرأة',
        isVolunteer: false,
        timeAgo: 'منذ شهر',
        avatar: 'assets/images/profile.png',
        caption: 'من اعظم اسباب تجعلك سعيداً في الحياه',
        likes: 234,
        comments: 45,
        shares: 18,
        isLiked: true,
        video: 'assets/videos/onboarding_video_1.mp4'
      }
    ];
    let activeReelIdx = 0;

    function renderReel(idx) {
      if (idx < 0) idx = reelsList.length - 1;
      if (idx >= reelsList.length) idx = 0;
      activeReelIdx = idx;

      const reel = reelsList[activeReelIdx];
      const video = document.getElementById('reels-video');
      if (video) {
        video.src = reel.video;
        video.load();
        video.play().catch(() => {});
      }

      const sName = document.getElementById('reel-sheikh-name');
      if (sName) sName.innerText = reel.userName;

      const sRole = document.getElementById('reel-sheikh-role');
      if (sRole) sRole.innerText = reel.userRole;

      const sBadge = document.getElementById('reel-volunteer-badge');
      if (sBadge) sBadge.style.display = reel.isVolunteer ? 'inline-block' : 'none';

      const sTime = document.getElementById('reel-time-text');
      if (sTime) sTime.innerText = reel.timeAgo;

      const sCaption = document.getElementById('reel-caption-text');
      if (sCaption) sCaption.innerText = reel.caption;

      const sAvatar = document.getElementById('reel-avatar-img');
      if (sAvatar) {
        sAvatar.src = reel.avatar;
        sAvatar.style.display = 'block';
      }

      const sLikes = document.getElementById('reel-likes-num');
      if (sLikes) sLikes.innerText = reel.likes;

      const sComments = document.getElementById('reel-comments-num');
      if (sComments) sComments.innerText = reel.comments;

      const likeItem = document.getElementById('reel-like-item');
      if (likeItem) {
        if (reel.isLiked) {
          likeItem.classList.add('liked');
        } else {
          likeItem.classList.remove('liked');
        }
      }
    }

    function toggleFullscreenReel() {
      const v = document.getElementById('reels-video');
      if (!v) return;
      if (v.requestFullscreen) v.requestFullscreen();
      else if (v.webkitRequestFullscreen) v.webkitRequestFullscreen();
      else alert('⛶ وضع ملء الشاشة الكامل مفعّل');
    }

    function nextReel() {
      renderReel(activeReelIdx + 1);
    }

    function prevReel() {
      renderReel(activeReelIdx - 1);
    }

    function toggleLikeCurrentReel() {
      const reel = reelsList[activeReelIdx];
      reel.isLiked = !reel.isLiked;
      if (reel.isLiked) reel.likes += 1;
      else reel.likes -= 1;
      const sLikes = document.getElementById('reel-likes-num');
      if (sLikes) sLikes.innerText = reel.likes;
      const likeItem = document.getElementById('reel-like-item');
      if (likeItem) {
        if (reel.isLiked) likeItem.classList.add('liked');
        else likeItem.classList.remove('liked');
      }
    }

    function shareCurrentReel() {
      const reel = reelsList[activeReelIdx];
      alert('↗️ تم نسخ رابط المقطع لـ ' + reel.userName + ' للمشاركة');
    }

    function toggleReelPlayPause(event) {
      const video = document.getElementById('reels-video');
      const indicator = document.getElementById('reel-play-indicator');
      if (!video) return;

      if (video.paused) {
        video.play();
        if (indicator) indicator.style.display = 'none';
      } else {
        video.pause();
        if (indicator) indicator.style.display = 'flex';
      }
    }

    function openReelCommentsSheet() {
      const reel = reelsList[activeReelIdx];
      const modal = document.getElementById('reel-comments-modal');
      if (modal) {
        document.getElementById('comments-reel-count').innerText = reel.comments;
        modal.style.display = 'flex';
      }
    }

    function closeReelCommentsSheet() {
      const modal = document.getElementById('reel-comments-modal');
      if (modal) modal.style.display = 'none';
    }

    function submitReelComment() {
      const input = document.getElementById('reel-new-comment-input');
      if (!input || !input.value.trim()) return;
      const text = input.value.trim();
      const list = document.getElementById('reel-comments-list');
      if (list) {
        const item = document.createElement('div');
        item.style.cssText = 'display: flex; gap: 10px; align-items: flex-start; padding: 8px 0; border-bottom: 1px solid #f0f0f0;';
        item.innerHTML = '<div style="width: 32px; height: 32px; border-radius: 50%; background: #E8F5E9; color: #00875A; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold;">أنت</div><div style="flex: 1;"><div style="font-size: 13px; font-weight: bold; color: #191919;">طالب إتقان</div><div style="font-size: 12px; color: #444; margin-top: 2px;">' + text + '</div></div>';
        list.prepend(item);
      }
      input.value = '';
      const reel = reelsList[activeReelIdx];
      reel.comments += 1;
      const sComments = document.getElementById('reel-comments-num');
      if (sComments) sComments.innerText = reel.comments;
      document.getElementById('comments-reel-count').innerText = reel.comments;
    }

    function showAddOptionsModal() {
      const modal = document.getElementById('add-content-modal');
      if (modal) modal.style.display = 'flex';
    }

    function closeAddOptionsModal() {
      const modal = document.getElementById('add-content-modal');
      if (modal) modal.style.display = 'none';
    }

    // ALL 11 CATEGORIES & SUBCATEGORIES FROM USER SCREENSHOTS (Images 3 - 10)
    function switchCategory(el, catName) {
      document.querySelectorAll('.cat-rail-btn').forEach(b => b.classList.remove('active'));
      el.classList.add('active');

      const box = document.getElementById('subcat-box');
      if (!box) return;

      if (catName === 'القاعدة النورانية') {
        // Images 3, 4, 5
        box.innerHTML = `
          <div class="subcat-level-card" onclick="openCallWithTitle('حلقة القاعدة النورانية - القسم الأول (المستوى الأول)')">
            <div class="subcat-level-banner">
              <div class="subcat-level-number-badge">1</div>
              <div class="subcat-level-title">القسم الاول</div>
            </div>
            <div class="subcat-level-subtitle">المستوى الأول</div>
          </div>
          <div class="subcat-level-card" onclick="openCallWithTitle('حلقة القاعدة النورانية - القسم الثاني (المستوى الثاني)')">
            <div class="subcat-level-banner">
              <div class="subcat-level-number-badge">2</div>
              <div class="subcat-level-title">القسم الثاني</div>
            </div>
            <div class="subcat-level-subtitle">المستوى الثاني</div>
          </div>
          <div class="subcat-level-card" onclick="openCallWithTitle('حلقة القاعدة النورانية - القسم الثالث (المستوى الثالث)')">
            <div class="subcat-level-banner">
              <div class="subcat-level-number-badge">3</div>
              <div class="subcat-level-title">القسم الثالث</div>
            </div>
            <div class="subcat-level-subtitle">المستوى الثالث</div>
          </div>
        `;
      } else if (catName === 'القرآن الكريم') {
        // Images 6 & 7
        box.innerHTML = `
          <div class="subcat-grid-2col">
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: الحفظ')">
              <img src="https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=300" class="subcat-photo-img" alt="الحفظ">
              <div class="subcat-photo-title">الحفظ</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: المراجعة')">
              <img src="https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=300" class="subcat-photo-img" alt="المراجعة">
              <div class="subcat-photo-title">المراجعة</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: التجويد')">
              <div style="height: 85px; background: #fafaf5; display: flex; align-items: center; justify-content: center; font-size: 28px;">📖</div>
              <div class="subcat-photo-title">التجويد</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: المدارسة')">
              <img src="https://images.unsplash.com/photo-1509062522246-3755977927d7?w=300" class="subcat-photo-img" alt="المدارسة">
              <div class="subcat-photo-title">المدارسة</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: المقرأة')">
              <img src="https://images.unsplash.com/photo-1590076215667-875d4ef2d7ee?w=300" class="subcat-photo-img" alt="المقرأة">
              <div class="subcat-photo-title">المقرأة</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: علوم القرآن')">
              <img src="https://images.unsplash.com/photo-1544717305-2782549b5136?w=300" class="subcat-photo-img" alt="علوم القرآن">
              <div class="subcat-photo-title">علوم القرآن</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: القراءات العشر')">
              <img src="https://images.unsplash.com/photo-1519817650390-64a93db51149?w=300" class="subcat-photo-img" alt="القراءات العشر">
              <div class="subcat-photo-title">القراءات العشر</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: المقامات الصوتية')">
              <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300" class="subcat-photo-img" alt="المقامات الصوتية">
              <div class="subcat-photo-title">المقامات الصوتية</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: التفسير')">
              <img src="https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=300" class="subcat-photo-img" alt="التفسير">
              <div class="subcat-photo-title">التفسير</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('حلقة القرآن الكريم: القراءات')">
              <div style="height: 85px; background: #fafaf5; display: flex; align-items: center; justify-content: center; font-size: 28px;">📜</div>
              <div class="subcat-photo-title">القراءات</div>
            </div>
          </div>
        `;
      } else if (catName === 'مقرأة إهداء الثواب') {
        // Image 8
        box.innerHTML = `
          <div class="subcat-grid-2col">
            <div class="subcat-photo-card" onclick="openCallWithTitle('مقرأة إهداء الثواب: رجال')">
              <img src="https://images.unsplash.com/photo-1544717305-2782549b5136?w=300" class="subcat-photo-img" alt="رجال">
              <div class="subcat-photo-title">رجال</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('مقرأة إهداء الثواب: نساء')">
              <img src="https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=300" class="subcat-photo-img" alt="نساء">
              <div class="subcat-photo-title">نساء</div>
            </div>
          </div>
        `;
      } else if (catName === 'السنة النبوية') {
        // Image 9
        box.innerHTML = `
          <div class="subcat-grid-2col">
            <div class="subcat-photo-card" onclick="openCallWithTitle('السنة النبوية: الحفظ')">
              <img src="https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=300" class="subcat-photo-img" alt="الحفظ">
              <div class="subcat-photo-title">الحفظ</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('السنة النبوية: علوم الحديث')">
              <img src="https://images.unsplash.com/photo-1544717305-2782549b5136?w=300" class="subcat-photo-img" alt="علوم الحديث">
              <div class="subcat-photo-title">علوم الحديث</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('السنة النبوية: شروح الأحاديث')">
              <img src="https://images.unsplash.com/photo-1519817650390-64a93db51149?w=300" class="subcat-photo-img" alt="شروح الأحاديث">
              <div class="subcat-photo-title">شروح الأحاديث</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('السنة النبوية: الإقراء لكتب السنة')">
              <img src="https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=300" class="subcat-photo-img" alt="الإقراء لكتب السنة">
              <div class="subcat-photo-title">الإقراء لكتب السنة</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('السنة النبوية: القراءة بالإسناد')">
              <div style="height: 85px; background: #fafaf5; display: flex; align-items: center; justify-content: center; font-size: 28px;">📜</div>
              <div class="subcat-photo-title">القراءة بالإسناد</div>
            </div>
          </div>
        `;
      } else if (catName === 'علوم أخرى') {
        // Image 10
        box.innerHTML = `
          <div class="subcat-grid-2col">
            <div class="subcat-photo-card" onclick="openCallWithTitle('علوم أخرى: الفقه')">
              <img src="https://images.unsplash.com/photo-1544717305-2782549b5136?w=300" class="subcat-photo-img" alt="الفقه">
              <div class="subcat-photo-title">الفقه</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('علوم أخرى: السيرة')">
              <img src="https://images.unsplash.com/photo-1519817650390-64a93db51149?w=300" class="subcat-photo-img" alt="السيرة">
              <div class="subcat-photo-title">السيرة</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('علوم أخرى: العقيدة')">
              <img src="https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=300" class="subcat-photo-img" alt="العقيدة">
              <div class="subcat-photo-title">العقيدة</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('علوم أخرى: الرقائق')">
              <img src="https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=300" class="subcat-photo-img" alt="الرقائق">
              <div class="subcat-photo-title">الرقائق</div>
            </div>
            <div class="subcat-photo-card" onclick="openCallWithTitle('علوم أخرى: تيست')">
              <div style="height: 85px; background: #fafaf5; display: flex; align-items: center; justify-content: center; font-size: 28px;">📷</div>
              <div class="subcat-photo-title">تيست</div>
            </div>
          </div>
        `;
      } else {
        box.innerHTML = `
          <div class="subcat-level-card" onclick="openCallWithTitle('حلقة: ` + catName + ` (المستوى العام)')">
            <div class="subcat-level-banner">
              <div class="subcat-level-number-badge">★</div>
              <div class="subcat-level-title">` + catName + `</div>
            </div>
            <div class="subcat-level-subtitle">دروس ومجالس حية مباشرة</div>
          </div>
        `;
      }
    }

    function openCallWithTitle
"@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldJsRegex, $newJs)
Write-Host "Updated JavaScript functions and reels data!"

# Save to preview.html and index.html
[System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)
$indexPath = "C:\Users\ESALAH30\.gemini\antigravity\scratch\etqan_flutter_project\index.html"
[System.IO.File]::WriteAllText($indexPath, $content, [System.Text.Encoding]::UTF8)
Write-Host "Done writing to preview.html and index.html!"
