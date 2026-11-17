# PowerShell script to update preview.html to 100% match original etqan_app Reels layout
$filePath = "C:\Users\ESALAH30\.gemini\antigravity\scratch\etqan_flutter_project\preview.html"
$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# 1. Update CSS
$oldCss = @"
    .reels-header-top {
      position: absolute;
      top: 40px;
      left: 14px;
      right: 14px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      z-index: 30;
    }
    .gold-comp-pill {
      background: #fff;
      border-radius: 24px;
      padding: 4px 12px;
      display: flex;
      align-items: center;
      gap: 6px;
      cursor: pointer;
      box-shadow: 0 4px 12px rgba(0,0,0,0.4);
    }
    .gold-comp-pill img {
      width: 26px;
      height: 26px;
    }
    .gold-comp-pill span {
      font-size: 12px;
      font-weight: bold;
      color: #b78103;
    }
    .reels-actions-bar {
      position: absolute;
      left: 14px;
      bottom: 85px;
      display: flex;
      flex-direction: column;
      gap: 16px;
      z-index: 30;
      align-items: center;
    }
    .action-circle-btn {
      width: 44px;
      height: 44px;
      background: rgba(0,0,0,0.5);
      backdrop-filter: blur(8px);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      border: 1px solid rgba(255,255,255,0.25);
      transition: transform 0.15s;
    }
    .action-circle-btn:active { transform: scale(0.9); }
    .action-circle-btn img {
      width: 22px;
      height: 22px;
      filter: brightness(0) invert(1);
    }
    .action-label {
      font-size: 11px;
      color: #fff;
      font-weight: bold;
      margin-top: 3px;
      text-shadow: 0 1px 3px rgba(0,0,0,0.8);
    }
    .reels-sheikh-info {
      position: absolute;
      right: 16px;
      bottom: 24px;
      left: 70px;
      z-index: 30;
    }
"@

$newCss = @"
    .reels-header-top {
      position: absolute;
      top: 40px;
      left: 16px;
      right: 16px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      z-index: 30;
      direction: rtl;
    }
    .reel-follow-btn {
      background: #00875A;
      color: #ffffff;
      border: none;
      border-radius: 20px;
      padding: 6px 18px;
      font-size: 13px;
      font-weight: bold;
      cursor: pointer;
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      transition: all 0.2s ease;
      font-family: inherit;
    }
    .reel-follow-btn.following {
      background: rgba(255, 255, 255, 0.25);
      backdrop-filter: blur(6px);
      color: #ffffff;
    }
    .reels-actions-bar {
      position: absolute;
      left: 16px;
      bottom: 70px;
      display: flex;
      flex-direction: column;
      gap: 18px;
      z-index: 30;
      align-items: center;
    }
    .reels-action-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      cursor: pointer;
      user-select: none;
      transition: transform 0.15s ease;
    }
    .reels-action-item:active {
      transform: scale(0.85);
    }
    .reels-action-icon {
      width: 38px;
      height: 38px;
      display: flex;
      align-items: center;
      justify-content: center;
      filter: drop-shadow(0 2px 5px rgba(0,0,0,0.7));
    }
    .reels-action-icon svg {
      width: 30px;
      height: 30px;
      fill: none;
      stroke: #ffffff;
      stroke-width: 2;
      transition: fill 0.2s, stroke 0.2s;
    }
    .reels-action-item.liked .reels-action-icon svg {
      fill: #ff4757;
      stroke: #ff4757;
    }
    .action-label {
      font-size: 12px;
      color: #ffffff;
      font-weight: bold;
      margin-top: 2px;
      text-shadow: 0 1px 3px rgba(0,0,0,0.9);
    }
    .reels-sheikh-info {
      position: absolute;
      right: 16px;
      bottom: 24px;
      left: 80px;
      z-index: 30;
      text-align: right;
      direction: rtl;
    }
    .reels-caption-text {
      color: #ffffff;
      font-size: 14px;
      font-weight: bold;
      line-height: 1.4;
      text-shadow: 0 2px 5px rgba(0,0,0,0.9);
    }
"@

if ($content.Contains($oldCss)) {
    $content = $content.Replace($oldCss, $newCss)
    Write-Host "Replaced Reels CSS successfully!"
} else {
    Write-Host "Warning: oldCss not matched exactly."
}

# 2. Update #screen-reels HTML
$oldHtml = @"
          <!-- Top Bar -->
          <div class="reels-header-top">
            <div class="gold-comp-pill" onclick="openScreen('competitions')">
              <img src="assets/images/badg_gold.png" alt="Gold Badge">
              <span>المسابقات &gt;</span>
            </div>

            <!-- Quick Reel Switcher & Add Button -->
            <div style="display: flex; align-items: center; gap: 8px;">
              <span id="reel-counter-badge" style="background: rgba(0,0,0,0.6); backdrop-filter: blur(6px); color: #fff; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; border: 1px solid rgba(255,255,255,0.2);">
                ▶️ ريل 1 من 2
              </span>
              <button onclick="document.getElementById('reel-upload-input').click()" style="background: #00875A; color: #fff; border: none; padding: 5px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; cursor: pointer; display: flex; align-items: center; gap: 4px;" title="إضافة فيديو من جهازك">
                <span>➕</span> أضف ريل
              </button>
              <input type="file" id="reel-upload-input" accept="video/*" onchange="uploadCustomReel(event)" style="display: none;">
            </div>

            <div style="display: flex; gap: 10px;">
              <span style="font-size: 18px; cursor: pointer;">🔔</span>
              <span style="font-size: 18px; cursor: pointer;">🔍</span>
            </div>
          </div>

          <!-- Vertical Reel Switch Controls (Previous / Next Floating Arrows) -->
          <div style="position: absolute; right: 14px; top: 48%; transform: translateY(-50%); display: flex; flex-direction: column; gap: 12px; z-index: 50;">
            <button onclick="prevReel()" style="width: 36px; height: 36px; border-radius: 50%; background: rgba(0,0,0,0.65); border: 1px solid rgba(255,255,255,0.25); color: #fff; font-size: 15px; cursor: pointer; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(4px);" title="الريل السابق">
              ▲
            </button>
            <button onclick="nextReel()" style="width: 36px; height: 36px; border-radius: 50%; background: rgba(0,0,0,0.65); border: 1px solid rgba(255,255,255,0.25); color: #fff; font-size: 15px; cursor: pointer; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(4px);" title="الريل التالي">
              ▼
            </button>
          </div>

          <!-- Left Actions Bar (Real SVGs) -->
          <div class="reels-actions-bar">
            <div style="display: flex; flex-direction: column; align-items: center;" onclick="likeReel(this)">
              <div class="action-circle-btn">
                <img src="assets/svgs/like_icon.svg" alt="Like" id="reel-like-img">
              </div>
              <span class="action-label" id="reel-likes-num">1.4k</span>
            </div>

            <div style="display: flex; flex-direction: column; align-items: center;" onclick="alert('💬 تم فتح قائمة التعليقات')">
              <div class="action-circle-btn">
                <img src="assets/svgs/Comment.svg" alt="Comment">
              </div>
              <span class="action-label" id="reel-comments-num">342</span>
            </div>

            <div style="display: flex; flex-direction: column; align-items: center;" onclick="alert('↗️ تم نسخ رابط المقطع للمشاركة')">
              <div class="action-circle-btn">
                <img src="assets/svgs/icon_share.svg" alt="Share">
              </div>
              <span class="action-label" id="reel-shares-num">180</span>
            </div>
          </div>

          <!-- Sheikh & Video Info Banner -->
          <div class="reels-sheikh-info">
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
              <strong style="font-size: 15px;" id="reel-sheikh-name">sheikh saad ali</strong>
              <span style="background: #00875A; padding: 2px 8px; border-radius: 6px; font-size: 10px; font-weight: bold;" id="reel-badge">متطوع</span>
              <span style="background: rgba(255,255,255,0.2); padding: 2px 8px; border-radius: 6px; font-size: 10px;" id="reel-institution">مؤسسة التعاون</span>
            </div>
            <div style="font-size: 11px; color: #ccc; margin-bottom: 4px;" id="reel-time">منذ شهر</div>
            <p style="font-size: 14px; font-weight: 500;" id="reel-title-text">مواعظ مؤثرة عن عظمة تلاوة القرآن وتدبر آياته</p>
          </div>
"@

$newHtml = @"
          <!-- Top Bar (Exact Match with etqan_app ReelsScreen: Sheikh Name & Avatar on Right, Follow Button on Left) -->
          <div class="reels-header-top">
            <!-- Sheikh Info (Right) -->
            <div style="display: flex; align-items: center; gap: 8px;">
              <div id="reel-sheikh-avatar" style="width: 36px; height: 36px; border-radius: 50%; background: rgba(255,255,255,0.25); display: flex; align-items: center; justify-content: center; color: #fff; font-size: 18px; border: 1px solid rgba(255,255,255,0.3); overflow: hidden;">
                <img id="reel-avatar-img" src="https://images.unsplash.com/photo-1544717305-2782549b5136?w=150" alt="Avatar" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.style.display='none'">
              </div>
              <span id="reel-sheikh-name" style="color: #ffffff; font-size: 15px; font-weight: bold; text-shadow: 0 1px 4px rgba(0,0,0,0.9);">د / عبد الله الرويلي</span>
            </div>

            <!-- Follow Button (Left) -->
            <button id="reel-follow-btn" class="reel-follow-btn" onclick="toggleFollowReel(event)">متابعة</button>
          </div>

          <!-- Central Play/Pause Tap Area -->
          <div onclick="toggleReelPlayPause(event)" style="position: absolute; inset: 60px 0 100px 0; z-index: 20; display: flex; align-items: center; justify-content: center; cursor: pointer;">
            <div id="reel-play-indicator" style="width: 72px; height: 72px; border-radius: 50%; background: rgba(0,0,0,0.5); backdrop-filter: blur(6px); display: none; align-items: center; justify-content: center; border: 2px solid rgba(255,255,255,0.4);">
              <svg viewBox="0 0 24 24" width="40" height="40" fill="#ffffff"><path d="M8 5v14l11-7z"/></svg>
            </div>
          </div>

          <!-- Left Floating Action Controls (Exact Match: Like, Comment, Share) -->
          <div class="reels-actions-bar">
            <!-- Like -->
            <div class="reels-action-item" id="reel-like-item" onclick="toggleLikeCurrentReel()">
              <div class="reels-action-icon">
                <svg id="reel-like-svg" viewBox="0 0 24 24">
                  <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                </svg>
              </div>
              <span class="action-label" id="reel-likes-num">234</span>
            </div>

            <!-- Comment -->
            <div class="reels-action-item" onclick="openReelCommentsSheet()">
              <div class="reels-action-icon">
                <svg viewBox="0 0 24 24">
                  <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/>
                </svg>
              </div>
              <span class="action-label" id="reel-comments-num">45</span>
            </div>

            <!-- Share -->
            <div class="reels-action-item" onclick="shareCurrentReel()">
              <div class="reels-action-icon">
                <svg viewBox="0 0 24 24">
                  <line x1="22" y1="2" x2="11" y2="13"></line>
                  <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                </svg>
              </div>
              <span class="action-label" style="font-size: 11px;">مشاركة</span>
            </div>
          </div>

          <!-- Bottom Video Caption (Right: 16, Bottom: 24, Left: 80) -->
          <div class="reels-sheikh-info">
            <div class="reels-caption-text" id="reel-caption-text">من اعظم اسباب تجعلك سعيداً في الحياه</div>
          </div>

          <!-- Subtle Up/Down Vertical Swipe Arrows on edge -->
          <div style="position: absolute; left: 8px; top: 50%; transform: translateY(-50%); display: flex; flex-direction: column; gap: 8px; z-index: 25; opacity: 0.35;">
            <div onclick="prevReel(); event.stopPropagation();" style="width: 26px; height: 26px; border-radius: 50%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; cursor: pointer; color: #fff; font-size: 11px;" title="المقطع السابق">▲</div>
            <div onclick="nextReel(); event.stopPropagation();" style="width: 26px; height: 26px; border-radius: 50%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; cursor: pointer; color: #fff; font-size: 11px;" title="المقطع التالي">▼</div>
          </div>
"@

if ($content.Contains($oldHtml)) {
    $content = $content.Replace($oldHtml, $newHtml)
    Write-Host "Replaced Reels HTML successfully!"
} else {
    Write-Host "Warning: oldHtml not matched exactly."
}

# 3. Update Bottom Nav Bar
$oldNav = @"
      <!-- Bottom Nav Bar (Using Actual SVGs) -->
      <div class="app-bottom-nav">
        <button class="nav-tab-item active" id="bnav-reels" onclick="openScreen('reels')">
          <img src="assets/svgs/home.svg" alt="Home">
          <span>الرئيسية</span>
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
"@

$newNav = @"
      <!-- Bottom Nav Bar (Exact Match with etqan_app MainNavScreen: الرئيسية، الحلقات، + اضافة، الشيوخ، المزيد) -->
      <div class="app-bottom-nav">
        <button class="nav-tab-item active" id="bnav-reels" onclick="openScreen('reels')">
          <img src="assets/svgs/home.svg" alt="Home">
          <span>الرئيسية</span>
        </button>
        <button class="nav-tab-item" id="bnav-chapters" onclick="openScreen('chapters')">
          <img src="assets/svgs/chapters_tab_icon.svg" alt="Chapters">
          <span>الحلقات</span>
        </button>
        <button class="nav-tab-item" id="bnav-add" onclick="showAddOptionsModal()" style="display: flex; flex-direction: column; align-items: center; background: none; border: none; cursor: pointer;">
          <div style="width: 44px; height: 44px; background: #191919; border: 2.5px solid #00875A; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 10px rgba(0,135,90,0.35); margin-top: -6px;">
            <span style="color: #00875A; font-size: 24px; font-weight: bold; line-height: 1;">+</span>
          </div>
          <span style="font-size: 11px; font-weight: bold; color: #191919; margin-top: 2px;">اضافة</span>
        </button>
        <button class="nav-tab-item" id="bnav-sheikhs" onclick="openScreen('sheikhs')">
          <img src="assets/svgs/supervisors.svg" alt="Sheikhs">
          <span>الشيوخ</span>
        </button>
        <button class="nav-tab-item" id="bnav-more" onclick="openScreen('more')">
          <img src="assets/svgs/more.svg" alt="More">
          <span>المزيد</span>
        </button>
      </div>
"@

if ($content.Contains($oldNav)) {
    $content = $content.Replace($oldNav, $newNav)
    Write-Host "Replaced Bottom Nav successfully!"
} else {
    Write-Host "Warning: oldNav not matched exactly."
}

# 4. Update JavaScript Reels Section
$oldJs = @"
    const reelsList = [
      {
        video: 'assets/videos/onboarding_video_1.mp4',
        sheikh: 'sheikh saad ali',
        badge: 'متطوع',
        institution: 'مؤسسة التعاون',
        time: 'منذ شهر',
        title: 'مواعظ مؤثرة عن عظمة تلاوة القرآن وتدبر آياته',
        likes: '1.4k',
        comments: '342',
        shares: '180'
      },
      {
        video: 'assets/videos/onboarding_video_2.mp4',
        sheikh: 'الشيخ محمود القزاز',
        badge: 'معتمد',
        institution: 'مقرأة الإتقان العامة',
        time: 'منذ أسبوع',
        title: 'شرح مفصل لمخارج الحروف وصفاتها - أحكام التجويد العملية',
        likes: '2.8k',
        comments: '580',
        shares: '310'
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
      if (sName) sName.innerText = reel.sheikh;
      const sBadge = document.getElementById('reel-badge');
      if (sBadge) sBadge.innerText = reel.badge;
      const sInst = document.getElementById('reel-institution');
      if (sInst) sInst.innerText = reel.institution;
      const sTime = document.getElementById('reel-time');
      if (sTime) sTime.innerText = reel.time;
      const sTitle = document.getElementById('reel-title-text');
      if (sTitle) sTitle.innerText = reel.title;
      const sLikes = document.getElementById('reel-likes-num');
      if (sLikes) sLikes.innerText = reel.likes;
      const sComments = document.getElementById('reel-comments-num');
      if (sComments) sComments.innerText = reel.comments;
      const sShares = document.getElementById('reel-shares-num');
      if (sShares) sShares.innerText = reel.shares;
      const sCounter = document.getElementById('reel-counter-badge');
      if (sCounter) sCounter.innerText = ``▶️ ريل `${activeReelIdx + 1} من `${reelsList.length}``;
    }

    function nextReel() {
      renderReel(activeReelIdx + 1);
    }

    function prevReel() {
      renderReel(activeReelIdx - 1);
    }

    function uploadCustomReel(event) {
      const file = event.target.files[0];
      if (!file) return;
      const url = URL.createObjectURL(file);
      const fileNameClean = file.name.replace(/\.[^/.]+$/, '');
      const title = prompt('أدخل عنوان هذا المقطع القرآني:', fileNameClean) || fileNameClean;
      const sheikh = prompt('أدخل اسم الشيخ أو القارئ:', 'قارئ جديد') || 'قارئ جديد';
      reelsList.push({
        video: url,
        sheikh: sheikh,
        badge: 'مقطع جديد',
        institution: 'تمت إضافته من جهازك',
        time: 'الآن',
        title: title,
        likes: '0',
        comments: '0',
        shares: '0'
      });
      renderReel(reelsList.length - 1);
      alert('🎉 تم إضافة وتشغيل الريل الجديد بنجاح في الواجهة!');
    }

    function likeReel(el) {
      const num = document.getElementById('reel-likes-num');
      const img = document.getElementById('reel-like-img');
      if (num.innerText === '1.4k') {
        num.innerText = '1.4k + 1';
        num.style.color = '#ff4d4f';
        img.style.filter = 'invert(27%) sepia(85%) saturate(3000%) hue-rotate(345deg)';
      } else {
        num.innerText = '1.4k';
        num.style.color = '#fff';
        img.style.filter = 'brightness(0) invert(1)';
      }
    }
"@

$newJs = @"
    const reelsList = [
      {
        sheikh: 'د / عبد الله الرويلي',
        avatar: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
        caption: 'من اعظم اسباب تجعلك سعيداً في الحياه',
        likes: 234,
        comments: 45,
        isFollowing: false,
        isLiked: false,
        video: 'assets/videos/onboarding_video_1.mp4'
      },
      {
        sheikh: 'د / مصطفي حسني',
        avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        caption: 'فضل قراءة وتدبر سورة الكهف يوم الجمعة وسر نورها',
        likes: 852,
        comments: 112,
        isFollowing: true,
        isLiked: false,
        video: 'assets/videos/onboarding_video_2.mp4'
      },
      {
        sheikh: 'د / محمد المطر',
        avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        caption: 'تصحيح مخرج حرف الضاد والظاء وأشهر الأخطاء الشائعة',
        likes: 419,
        comments: 63,
        isFollowing: false,
        isLiked: false,
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
      if (sName) sName.innerText = reel.sheikh;

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

      const followBtn = document.getElementById('reel-follow-btn');
      if (followBtn) {
        if (reel.isFollowing) {
          followBtn.innerText = 'متابع';
          followBtn.classList.add('following');
        } else {
          followBtn.innerText = 'متابعة';
          followBtn.classList.remove('following');
        }
      }

      const likeItem = document.getElementById('reel-like-item');
      if (likeItem) {
        if (reel.isLiked) {
          likeItem.classList.add('liked');
        } else {
          likeItem.classList.remove('liked');
        }
      }
    }

    function nextReel() {
      renderReel(activeReelIdx + 1);
    }

    function prevReel() {
      renderReel(activeReelIdx - 1);
    }

    function toggleFollowReel(event) {
      if (event) event.stopPropagation();
      const reel = reelsList[activeReelIdx];
      reel.isFollowing = !reel.isFollowing;
      const btn = document.getElementById('reel-follow-btn');
      if (reel.isFollowing) {
        btn.innerText = 'متابع';
        btn.classList.add('following');
      } else {
        btn.innerText = 'متابعة';
        btn.classList.remove('following');
      }
    }

    function toggleLikeCurrentReel() {
      const reel = reelsList[activeReelIdx];
      reel.isLiked = !reel.isLiked;
      if (reel.isLiked) {
        reel.likes += 1;
      } else {
        reel.likes -= 1;
      }
      const sLikes = document.getElementById('reel-likes-num');
      if (sLikes) sLikes.innerText = reel.likes;

      const likeItem = document.getElementById('reel-like-item');
      if (likeItem) {
        if (reel.isLiked) {
          likeItem.classList.add('liked');
        } else {
          likeItem.classList.remove('liked');
        }
      }
    }

    function shareCurrentReel() {
      const reel = reelsList[activeReelIdx];
      alert('↗️ تم نسخ رابط المقطع لـ ' + reel.sheikh + ' للمشاركة');
    }

    function toggleReelPlayPause(event) {
      const video = document.getElementById('reels-video');
      const indicator = document.getElementById('reel-play-indicator');
      if (!video) return;

      if (video.paused) {
        video.play();
        if (indicator) {
          indicator.style.display = 'none';
        }
      } else {
        video.pause();
        if (indicator) {
          indicator.style.display = 'flex';
        }
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
        item.innerHTML = `
          <div style="width: 32px; height: 32px; border-radius: 50%; background: #E8F5E9; color: #00875A; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold;">أنت</div>
          <div style="flex: 1;">
            <div style="font-size: 13px; font-weight: bold; color: #191919;">طالب إتقان</div>
            <div style="font-size: 12px; color: #444; margin-top: 2px;">` + text + `</div>
          </div>
        `;
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
"@

if ($content.Contains($oldJs)) {
    $content = $content.Replace($oldJs, $newJs)
    Write-Host "Replaced Reels JS successfully!"
} else {
    Write-Host "Warning: oldJs not matched exactly."
}

# 5. Add Modals for Comments and Add Content before </body>
$modalsHtml = @"
  <!-- MODAL: ADD CONTENT (Exact Match with etqan_app MainNavScreen _showAddOptionsBottomSheet) -->
  <div id="add-content-modal" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); z-index: 9999; justify-content: center; align-items: flex-end;" onclick="closeAddOptionsModal()">
    <div style="background: #ffffff; width: 100%; max-width: 420px; border-radius: 24px 24px 0 0; padding: 24px; box-shadow: 0 -8px 24px rgba(0,0,0,0.2); direction: rtl;" onclick="event.stopPropagation()">
      <div style="width: 40px; height: 4px; background: #ddd; border-radius: 4px; margin: 0 auto 18px auto;"></div>
      <div style="font-size: 18px; font-weight: bold; color: #191919; margin-bottom: 20px; text-align: center;">إضافة محتوى جديد</div>

      <!-- Option 1: Upload Reel -->
      <div style="display: flex; align-items: center; gap: 14px; padding: 14px; border-radius: 14px; background: #F8FAF9; margin-bottom: 12px; cursor: pointer; border: 1px solid #E2E8F0;" onclick="closeAddOptionsModal(); alert('📹 فتح استوديو تسجيل ورفع فيديو تعليمي / Reel');">
        <div style="width: 44px; height: 44px; border-radius: 50%; background: #E8F5E9; display: flex; align-items: center; justify-content: center; font-size: 22px; color: #00875A;">📹</div>
        <div style="flex: 1;">
          <div style="font-size: 15px; font-weight: bold; color: #191919;">رفع فيديو تعليمي / Reel</div>
          <div style="font-size: 12px; color: #64748B; margin-top: 2px;">نشر مقطع تجويد أو تلاوة أو موعظة للمتابعين</div>
        </div>
      </div>

      <!-- Option 2: Create Quran Circle -->
      <div style="display: flex; align-items: center; gap: 14px; padding: 14px; border-radius: 14px; background: #F8FAF9; margin-bottom: 18px; cursor: pointer; border: 1px solid #E2E8F0;" onclick="closeAddOptionsModal(); alert('👥 فتح نموذج إنشاء حلقة قرآنية جديدة واستقبال الطلاب');">
        <div style="width: 44px; height: 44px; border-radius: 50%; background: #E3F2FD; display: flex; align-items: center; justify-content: center; font-size: 22px; color: #1976D2;">👥</div>
        <div style="flex: 1;">
          <div style="font-size: 15px; font-weight: bold; color: #191919;">إنشاء حلقة قرآنية جديدة</div>
          <div style="font-size: 12px; color: #64748B; margin-top: 2px;">تحديد موعد جلسة تحفيظ أو مراجعة واستقبال الطلاب</div>
        </div>
      </div>

      <button onclick="closeAddOptionsModal()" style="width: 100%; padding: 12px; background: #f0f0f0; border: none; border-radius: 12px; font-size: 14px; font-weight: bold; color: #555; cursor: pointer;">إلغاء</button>
    </div>
  </div>

  <!-- MODAL: REEL COMMENTS SHEET -->
  <div id="reel-comments-modal" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); z-index: 9999; justify-content: center; align-items: flex-end;" onclick="closeReelCommentsSheet()">
    <div style="background: #ffffff; width: 100%; max-width: 420px; height: 460px; border-radius: 24px 24px 0 0; padding: 20px; box-shadow: 0 -8px 24px rgba(0,0,0,0.2); direction: rtl; display: flex; flex-direction: column;" onclick="event.stopPropagation()">
      <div style="width: 40px; height: 4px; background: #ddd; border-radius: 4px; margin: 0 auto 12px auto;"></div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; border-bottom: 1px solid #eee; padding-bottom: 10px;">
        <span style="font-size: 16px; font-weight: bold; color: #191919;">التعليقات (<span id="comments-reel-count">45</span>)</span>
        <button onclick="closeReelCommentsSheet()" style="background: none; border: none; font-size: 18px; color: #888; cursor: pointer;">✕</button>
      </div>

      <!-- Comments List -->
      <div id="reel-comments-list" style="flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; padding-bottom: 10px;">
        <div style="display: flex; gap: 10px; align-items: flex-start; padding: 8px 0; border-bottom: 1px solid #f0f0f0;">
          <div style="width: 32px; height: 32px; border-radius: 50%; background: #E8F5E9; color: #00875A; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold;">أ</div>
          <div style="flex: 1;">
            <div style="font-size: 13px; font-weight: bold; color: #191919;">أحمد سمير</div>
            <div style="font-size: 12px; color: #444; margin-top: 2px;">جزاكم الله خير الجزاء يا شيخنا ونفع بكم الإسلام والمسلمين</div>
          </div>
        </div>
        <div style="display: flex; gap: 10px; align-items: flex-start; padding: 8px 0; border-bottom: 1px solid #f0f0f0;">
          <div style="width: 32px; height: 32px; border-radius: 50%; background: #E8F5E9; color: #00875A; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold;">ع</div>
          <div style="flex: 1;">
            <div style="font-size: 13px; font-weight: bold; color: #191919;">عبد الرحمن خالد</div>
            <div style="font-size: 12px; color: #444; margin-top: 2px;">ما شاء الله تبارك الله، تلاوة خاشعة وشرح وتوضيح متقن للغاية</div>
          </div>
        </div>
        <div style="display: flex; gap: 10px; align-items: flex-start; padding: 8px 0;">
          <div style="width: 32px; height: 32px; border-radius: 50%; background: #E8F5E9; color: #00875A; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold;">م</div>
          <div style="flex: 1;">
            <div style="font-size: 13px; font-weight: bold; color: #191919;">محمد الشريف</div>
            <div style="font-size: 12px; color: #444; margin-top: 2px;">اللهم اجعلنا وإياكم من أهل القرآن وخاصته</div>
          </div>
        </div>
      </div>

      <!-- Add Comment Input -->
      <div style="display: flex; gap: 8px; padding-top: 10px; border-top: 1px solid #eee;">
        <input type="text" id="reel-new-comment-input" placeholder="أضف تعليقاً طيباً..." style="flex: 1; padding: 10px 14px; border: 1px solid #ddd; border-radius: 20px; font-size: 13px; outline: none; font-family: inherit;">
        <button onclick="submitReelComment()" style="background: #00875A; color: #fff; border: none; padding: 8px 18px; border-radius: 20px; font-size: 13px; font-weight: bold; cursor: pointer;">إرسال</button>
      </div>
    </div>
  </div>
"@

if (-not $content.Contains("id=`"add-content-modal`"")) {
    $content = $content.Replace("</body>", "$modalsHtml`n</body>")
    Write-Host "Added Modals HTML successfully!"
}

[System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)
Write-Host "Done updating preview.html!"
