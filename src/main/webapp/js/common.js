/**
 * BBS论坛系统 - 公共JavaScript
 * 日期: 2026-05-30
 */

// Ajax 封装
const $ = {
    // GET请求
    get: function(url, callback) {
        fetch(url, { method: 'GET', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(res => res.json())
            .then(data => callback(data))
            .catch(err => console.error('GET Error:', err));
    },

    // POST请求
    post: function(url, data, callback) {
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: new URLSearchParams(data).toString()
        })
        .then(res => res.json())
        .then(data => callback(data))
        .catch(err => console.error('POST Error:', err));
    }
};

// 确认删除
function confirmDelete(msg) {
    return confirm(msg || '确定要删除吗？');
}

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 给当前页面对应的导航加 active
    var path = window.location.pathname;
    document.querySelectorAll('.nav-links a').forEach(function(a) {
        if (a.getAttribute('href') === path) {
            a.classList.add('active');
        }
    });

    // 给侧边栏对应项加 active
    document.querySelectorAll('.side-item a').forEach(function(a) {
        if (a.getAttribute('href') === path) {
            a.classList.add('active');
        }
    });
});

// 修复浏览器返回按钮不刷新（bfcache 问题）
window.addEventListener('pageshow', function(event) {
    if (event.persisted) {
        window.location.reload();
    }
});

// ============================================
// BBSForum 三主题切换引擎
// ============================================

// 主题元数据
const THEME_THEMES = {
    default: { label: '默认', icon: 'fa-sun-o' },
    tech:    { label: '极客', icon: 'fa-moon-o' },
    doodle:  { label: '涂鸦', icon: 'fa-pencil-square-o' }
};

// 主题颜色映射
const THEME_COLORS = {
    default: {},
    tech: {
        // 背景 — The Void
        '.bg-white': '#1a103c',
        '.bg-gray-100': '#0d0720',
        '.bg-gray-50': '#0a0518',
        '.bg-blue-50': '#0d0030',
        '.bg-blue-100': 'rgba(0,255,255,0.10)',
        '.bg-red-50': '#200020',
        '.bg-red-100': 'rgba(255,0,255,0.12)',
        '.bg-orange-50': '#201000',
        '.bg-green-50': '#002010',
        '.bg-green-100': 'rgba(0,255,255,0.10)',
        '.bg-pink-50': 'rgba(255,0,255,0.12)',
        '.bg-pink-100': 'rgba(255,0,255,0.15)',
        '.bg-yellow-50': 'rgba(255,153,0,0.10)',
        '.bg-yellow-100': 'rgba(255,153,0,0.12)',
        '.bg-amber-50': 'rgba(255,153,0,0.10)',
        '.bg-amber-100': 'rgba(255,153,0,0.15)',
        '.bg-purple-50': 'rgba(255,0,255,0.10)',
        '.bg-purple-100': 'rgba(255,0,255,0.15)',
        '.bg-black\\/40': 'rgba(0,0,0,0.7)',
        // 文字 — Chrome Text
        '.text-gray-700': '#E0E0E0',
        '.text-gray-600': 'rgba(224,224,224,0.85)',
        '.text-gray-800': '#E0E0E0',
        '.text-gray-500': 'rgba(224,224,224,0.7)',
        '.text-gray-400': 'rgba(224,224,224,0.55)',
        '.text-gray-900': '#E0E0E0',
        '.text-red-500': '#FF00FF',
        '.text-red-600': '#FF00FF',
        '.text-red-700': 'rgba(255,0,255,0.8)',
        '.text-blue-500': '#00FFFF',
        '.text-blue-600': '#00FFFF',
        '.text-blue-700': 'rgba(0,255,255,0.8)',
        '.text-blue-400': '#00FFFF',
        '.text-green-500': '#00FFFF',
        '.text-green-600': '#00FFFF',
        '.text-green-700': 'rgba(0,255,255,0.8)',
        '.text-orange-500': '#FF9900',
        '.text-orange-600': '#FF9900',
        '.text-orange-700': 'rgba(255,153,0,0.8)',
        '.text-purple-500': '#FF00FF',
        '.text-purple-600': '#FF00FF',
        '.text-pink-500': '#FF00FF',
        '.text-pink-600': '#FF00FF',
        '.text-pink-700': 'rgba(255,0,255,0.8)',
        '.text-yellow-500': '#FF9900',
        '.text-yellow-600': '#FF9900',
        '.text-yellow-700': 'rgba(255,153,0,0.8)',
        '.text-amber-400': '#FF9900',
        '.text-amber-500': '#FF9900',
        '.text-amber-600': '#FF9900',
        '.text-white': '#E0E0E0',
        // 边框 — Neon Tubes
        '.border-gray-200': '#2D1B4E',
        '.border-gray-100': 'rgba(45,27,78,0.5)',
        '.border-gray-300': '#FF00FF',
        '.border-gray-50': 'rgba(45,27,78,0.3)',
        '.border-blue-200': '#00FFFF',
        '.border-blue-500': '#00FFFF',
        '.border-orange-200': '#FF9900',
        '.border-orange-300': '#FF9900',
        '.border-red-200': '#FF00FF',
        '.border-green-200': '#00FFFF',
        '.border-pink-200': '#FF00FF',
        '.border-yellow-200': '#FF9900',
        '.border-amber-200': '#FF9900',
        // Hover
        '.hover\\:bg-blue-500:hover': '#0a0a1a',
        '.hover\\:bg-blue-50:hover': '#1a0050',
        '.hover\\:bg-blue-100:hover': 'rgba(0,255,255,0.15)',
        '.hover\\:bg-gray-100:hover': '#120830',
        '.hover\\:bg-gray-50:hover': '#0e0628',
        '.hover\\:bg-orange-100:hover': '#201000',
        '.hover\\:bg-red-50:hover': '#200020',
        '.hover\\:bg-red-100:hover': 'rgba(255,0,255,0.15)',
        '.hover\\:bg-green-100:hover': 'rgba(0,255,255,0.15)',
        '.hover\\:bg-pink-100:hover': 'rgba(255,0,255,0.20)',
        '.hover\\:bg-yellow-50:hover': 'rgba(255,153,0,0.15)',
        '.hover\\:bg-purple-100:hover': 'rgba(255,0,255,0.20)',
        '.hover\\:bg-amber-100:hover': 'rgba(255,153,0,0.20)',
        '.hover\\:text-blue-500:hover': '#00FFFF',
        '.hover\\:text-blue-600:hover': '#00FFFF',
        '.hover\\:text-blue-800:hover': '#00FFFF',
        '.hover\\:text-red-500:hover': '#FF00FF',
        '.hover\\:text-red-600:hover': '#FF00FF',
        '.hover\\:text-red-700:hover': '#FF00FF',
        '.hover\\:text-orange-500:hover': '#FF9900',
        '.hover\\:text-green-600:hover': '#00FFFF',
        '.hover\\:border-blue-500:hover': '#00FFFF',
        '.hover\\:border-red-200:hover': '#FF00FF',
        '.hover\\:border-gray-300:hover': '#00FFFF',
        // 其他
        '.bg-gray-200': 'rgba(26,16,60,0.6)',
        '.bg-gray-900': 'rgba(0,0,0,0.7)',
        '.bg-blue-500': '#1a0030',
        '.text-gray-100': 'rgba(224,224,224,0.9)',
        '.ring-blue-200': 'rgba(0,255,255,0.3)',
        '.focus\\:border-blue-400:focus': '#00FFFF',
        '.focus\\:ring-blue-200:focus': 'rgba(0,255,255,0.25)',
        '.hover\\:bg-blue-600:hover': 'rgba(0,255,255,0.20)',
        '.hover\\:bg-gray-200:hover': 'rgba(255,255,255,0.08)',
        '.hover\\:bg-gray-300:hover': 'rgba(255,255,255,0.12)',
    },
    doodle: {
        // 背景色
        '.bg-white': '#fffdf5',
        '.bg-gray-100': '#f5f0e8',
        '.bg-gray-50': '#faf5eb',
        '.bg-blue-50': '#f0e8d0',
        '.bg-blue-100': '#e0d8c0',
        '.bg-red-50': '#f5e8e0',
        '.bg-red-100': '#f0e0d8',
        '.bg-orange-50': '#f5e8d0',
        '.bg-green-50': '#e8f0d0',
        '.bg-green-100': '#d8e0c8',
        '.bg-pink-50': '#f5e8e0',
        '.bg-pink-100': '#f0e0d8',
        '.bg-yellow-50': '#f5e8d0',
        '.bg-yellow-100': '#f0e0c8',
        '.bg-amber-50': '#f5e8d0',
        '.bg-amber-100': '#f0e0c8',
        '.bg-purple-50': '#f0e8d8',
        '.bg-purple-100': '#e8dcc8',
        '.bg-black\\/40': 'rgba(60,40,20,0.3)',
        // 文字色
        '.text-gray-700': '#5c4033',
        '.text-gray-600': '#6b4c3a',
        '.text-gray-800': '#4a3528',
        '.text-gray-500': '#8b6f5a',
        '.text-gray-400': '#a0806a',
        '.text-gray-900': '#3a2518',
        '.text-red-500': '#c0392b',
        '.text-red-600': '#c0392b',
        '.text-red-700': '#a03020',
        '.text-blue-500': '#8b6914',
        '.text-blue-600': '#7a5a10',
        '.text-blue-700': '#6a4a08',
        '.text-blue-400': '#9a7a24',
        '.text-green-500': '#5a8b3a',
        '.text-green-600': '#5a8b3a',
        '.text-green-700': '#4a7a2a',
        '.text-orange-500': '#c07020',
        '.text-orange-600': '#c07020',
        '.text-orange-700': '#a06010',
        '.text-purple-500': '#8a5a7a',
        '.text-purple-600': '#8a5a7a',
        '.text-pink-500': '#c0392b',
        '.text-pink-600': '#c0392b',
        '.text-pink-700': '#a03020',
        '.text-yellow-500': '#c07020',
        '.text-yellow-600': '#c07020',
        '.text-yellow-700': '#a06010',
        '.text-amber-400': '#c07020',
        '.text-amber-500': '#c07020',
        '.text-amber-600': '#c07020',
        '.text-white': '#3a2518',
        // 边框色
        '.border-gray-200': '#e0d5c0',
        '.border-gray-100': '#e8ddd0',
        '.border-gray-300': '#d0c5b0',
        '.border-gray-50': '#f0e8d8',
        '.border-blue-200': '#c8b890',
        '.border-blue-500': '#d4a030',
        '.border-orange-200': '#d8c090',
        '.border-orange-300': '#d8b090',
        '.border-red-200': '#d8b0a0',
        '.border-green-200': '#b8c8a0',
        '.border-pink-200': '#d8b0a0',
        '.border-yellow-200': '#d8c090',
        '.border-amber-200': '#d8c090',
        // 鼠标悬停
        '.hover\\:bg-blue-500:hover': '#c89820',
        '.hover\\:bg-blue-50:hover': '#e8dcc0',
        '.hover\\:bg-blue-100:hover': '#d8d0b8',
        '.hover\\:bg-gray-100:hover': '#ece4d6',
        '.hover\\:bg-gray-50:hover': '#f0e8d8',
        '.hover\\:bg-orange-100:hover': '#f0e0c8',
        '.hover\\:bg-red-50:hover': '#f0e0d8',
        '.hover\\:bg-red-100:hover': '#e8d0c8',
        '.hover\\:bg-green-100:hover': '#c8d8b0',
        '.hover\\:bg-pink-100:hover': '#e8d0c8',
        '.hover\\:bg-yellow-50:hover': '#f0e0c8',
        '.hover\\:bg-purple-100:hover': '#e8dcc0',
        '.hover\\:bg-amber-100:hover': '#e8d8c0',
        '.hover\\:text-blue-500:hover': '#b8860b',
        '.hover\\:text-blue-600:hover': '#a07008',
        '.hover\\:text-blue-800:hover': '#906008',
        '.hover\\:text-red-500:hover': '#c0392b',
        '.hover\\:text-red-600:hover': '#c0392b',
        '.hover\\:text-red-700:hover': '#8b0000',
        '.hover\\:text-orange-500:hover': '#c07020',
        '.hover\\:text-green-600:hover': '#4a7a2a',
        '.hover\\:border-blue-500:hover': '#d4a030',
        '.hover\\:border-red-200:hover': '#c0392b',
        '.hover\\:border-gray-300:hover': '#8b6914',
        // 其他
        '.bg-gray-200': '#eee5d6',
        '.bg-gray-900': '#3a2518',
        '.bg-blue-500': '#d4a030',
        '.text-gray-100': '#f5f0e8',
        '.ring-blue-200': 'rgba(180,130,40,0.2)',
        '.focus\\:border-blue-400:focus': '#d4a030',
        '.focus\\:ring-blue-200:focus': 'rgba(180,130,40,0.2)',
        '.hover\\:bg-blue-600:hover': 'rgba(180,130,40,0.15)',
        '.hover\\:bg-gray-200:hover': '#e8ddd0',
        '.hover\\:bg-gray-300:hover': '#ddd2c2',
    }
};

// 主题特效 CSS
const THEME_EFFECTS = {
    default: `
        /* 默认主题：干净微质感 */
        .sticky header { box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
        ::selection { background: rgba(22,119,255,0.18); color: inherit; }
        .bg-white { transition: box-shadow 0.3s, transform 0.2s; }
        .bg-white:hover { box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
    `,
    tech: `
        /* ============================================
           Vaporwave / Outrun — Digital Nostalgia
           赛博霓虹 · 合成器浪潮 · 终端美学
           ============================================ */

        /* ---------- 关键帧动画 ---------- */
        @keyframes neon-pulse {
            0%, 100% { box-shadow: 0 0 10px rgba(255,0,255,0.3), 0 0 20px rgba(0,255,255,0.1); }
            50% { box-shadow: 0 0 20px rgba(255,0,255,0.5), 0 0 40px rgba(0,255,255,0.2); }
        }
        @keyframes cursor-blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0; }
        }

        /* ========== 全局 CRT 扫描线 ========== */
        body::after {
            content: '' !important;
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            pointer-events: none !important;
            z-index: 9999 !important;
            background: repeating-linear-gradient(
                0deg,
                rgba(0,0,0,0.06) 0px,
                rgba(0,0,0,0.06) 1px,
                transparent 1px,
                transparent 3px
            ) !important;
        }

        /* ========== 背景 — The Void ========== */
        body {
            background-color: #090014 !important;
            background-image:
                radial-gradient(circle, rgba(255,0,255,0.05) 1px, transparent 1px),
                radial-gradient(ellipse at 50% 15%, rgba(255,153,0,0.10) 0%, transparent 45%),
                radial-gradient(ellipse at 80% 80%, rgba(255,0,255,0.08) 0%, transparent 40%),
                radial-gradient(ellipse at 20% 60%, rgba(0,255,255,0.06) 0%, transparent 40%) !important;
            background-size: 20px 20px, 100% 100%, 100% 100%, 100% 100% !important;
        }

        /* ========== 头部 ========== */
        header {
            background: rgba(9,0,20,0.95) !important;
            border-bottom: 2px solid #FF00FF !important;
            box-shadow: 0 0 15px rgba(255,0,255,0.15) !important;
        }
        header a { color: #E0E0E0 !important; }
        header a:hover { color: #00FFFF !important; }
        .theme-btn { color: rgba(224,224,224,0.45) !important; }
        .theme-btn:hover { color: #00FFFF !important; }

        /* ========== 卡片 — 玻璃面板 ========== */
        .bg-white, .post-card, .auth-card, .profile-header,
        .stat-card, .quick-item, .data-table {
            background: rgba(26,16,60,0.80) !important;
            backdrop-filter: blur(4px) !important;
            border: 1px solid #2D1B4E !important;
            border-top: 2px solid #00FFFF !important;
            border-radius: 0 !important;
            box-shadow: 0 0 10px rgba(255,0,255,0.08) !important;
            transition: all 0.2s ease !important;
        }
        .bg-white:hover, .post-card:hover {
            box-shadow: 0 0 20px rgba(255,0,255,0.18), 0 0 40px rgba(0,255,255,0.08) !important;
            transform: translateY(-2px) !important;
            border-color: #FF00FF !important;
        }

        /* ========== 标题 — Orbitron + 全大写 ========== */
        h1, h2, h3, h4, h5, h6,
        .font-bold, .font-semibold, .text-lg.font-semibold,
        .text-xs.font-semibold {
            font-family: "Orbitron", sans-serif !important;
            text-transform: uppercase !important;
            letter-spacing: 0.05em !important;
            color: #00FFFF !important;
            text-shadow: 0 0 8px rgba(0,255,255,0.3) !important;
        }

        /* ========== 正文字体 — Share Tech Mono ========== */
        body, .text-sm, .text-xs, .text-base, .text-lg, p, span:not([class*="fa"]),
        li, td, th, label, small, a, button, input, textarea, select {
            font-family: "Share Tech Mono", monospace !important;
        }
        /* Font Awesome 图标保留 */
        i, .fa, [class*="fa-"] {
            font-family: FontAwesome !important;
        }

        /* ========== 页脚 ========== */
        footer {
            background: rgba(9,0,20,0.98) !important;
            border-top: 2px solid #00FFFF !important;
            box-shadow: 0 -2px 15px rgba(0,255,255,0.08) !important;
            color: rgba(224,224,224,0.4) !important;
        }

        /* ========== 链接 ========== */
        a:not(.no-underline) { color: #00FFFF !important; }
        a:not(.no-underline):hover {
            color: #FF00FF !important;
            text-shadow: 0 0 8px rgba(255,0,255,0.4) !important;
        }

        /* ========== 按钮 — Skewed 霓虹 ========== */
        .btn-primary, .btn-publish, [class*="bg-blue-500"]:not([class*="rounded-f"]) {
            font-family: "Share Tech Mono", monospace !important;
            text-transform: uppercase !important;
            letter-spacing: 0.1em !important;
            background: transparent !important;
            border: 2px solid #00FFFF !important;
            border-radius: 0 !important;
            color: #00FFFF !important;
            transform: skewX(-12deg) !important;
            box-shadow: 0 0 10px rgba(0,255,255,0.15) !important;
            transition: all 0.2s ease !important;
            padding: 8px 20px !important;
        }
        .btn-primary:hover, .btn-publish:hover,
        [class*="bg-blue-500"]:not([class*="rounded-f"]):hover {
            transform: skewX(0deg) scale(1.05) !important;
            background: #00FFFF !important;
            color: #090014 !important;
            box-shadow: 0 0 25px rgba(0,255,255,0.5) !important;
        }

        /* ========== 分页器 ========== */
        .pagination a {
            font-family: "Share Tech Mono", monospace !important;
            border: 1px solid #2D1B4E !important;
            border-radius: 0 !important;
            color: rgba(224,224,224,0.6) !important;
            background: rgba(26,16,60,0.6) !important;
        }
        .pagination a.active {
            background: transparent !important;
            border: 2px solid #00FFFF !important;
            color: #00FFFF !important;
            box-shadow: 0 0 15px rgba(0,255,255,0.3) !important;
        }
        .pagination a:hover:not(.active) {
            border-color: #FF00FF !important;
            color: #FF00FF !important;
            box-shadow: 0 0 10px rgba(255,0,255,0.15) !important;
        }

        /* ========== 侧栏 ========== */
        .side-item a.active, [class*="bg-blue-50"] {
            background: rgba(255,0,255,0.10) !important;
            border-left: 2px solid #00FFFF !important;
        }
        .side-item a { border-left: 2px solid transparent !important; }
        .side-item a:hover {
            border-left-color: #FF00FF !important;
            background: rgba(255,0,255,0.05) !important;
        }

        /* ========== 输入框 — 终端风格 ========== */
        input, textarea, select {
            font-family: "Share Tech Mono", monospace !important;
            background: rgba(0,0,0,0.5) !important;
            border: none !important;
            border-bottom: 2px solid #FF00FF !important;
            border-radius: 0 !important;
            color: #00FFFF !important;
            padding: 8px 12px !important;
            transition: all 0.2s !important;
        }
        textarea { border: 2px solid #FF00FF !important; }
        input:focus, textarea:focus, select:focus {
            border-bottom-color: #00FFFF !important;
            box-shadow: 0 0 15px rgba(0,255,255,0.15) !important;
            outline: none !important;
            background: rgba(0,0,0,0.7) !important;
        }
        input::placeholder, textarea::placeholder {
            color: rgba(255,0,255,0.35) !important;
        }

        /* ========== 表格 ========== */
        .data-table th {
            background: rgba(255,0,255,0.10) !important;
            color: #00FFFF !important;
            font-family: "Orbitron", sans-serif !important;
            text-transform: uppercase !important;
            letter-spacing: 0.1em !important;
            border-bottom: 2px solid #FF00FF !important;
        }
        .data-table td { border-color: rgba(45,27,78,0.5) !important; }

        /* ========== Badge / 标签 ========== */
        .badge-top {
            background: rgba(255,153,0,0.15) !important;
            color: #FF9900 !important;
            border: 1px solid #FF9900 !important;
            border-radius: 0 !important;
        }
        .badge-elite {
            background: rgba(255,0,255,0.15) !important;
            color: #FF00FF !important;
            border: 1px solid #FF00FF !important;
            border-radius: 0 !important;
        }
        /* 置顶/精华标签 */
        [class*="bg-red-50"], [class*="bg-pink-50"] {
            background: rgba(255,0,255,0.12) !important;
            border-color: #FF00FF !important;
            border-radius: 0 !important;
        }

        /* ========== 选中色 ========== */
        ::selection { background: rgba(255,0,255,0.35); color: #E0E0E0; }

        /* ========== 分隔线 ========== */
        .border-b, .border-t {
            border-color: rgba(45,27,78,0.5) !important;
        }

        /* ========== 弹窗 — 终端窗口 ========== */
        #modalBox {
            border: 2px solid #00FFFF !important;
            border-radius: 0 !important;
            box-shadow: 0 0 30px rgba(0,255,255,0.25), 0 0 60px rgba(255,0,255,0.10) !important;
            background: rgba(9,0,20,0.95) !important;
        }
        #modalOverlay { background: rgba(0,0,0,0.8) !important; }
        #modalTitle {
            font-family: "Orbitron", sans-serif !important;
            color: #00FFFF !important;
            text-transform: uppercase !important;
        }
        #modalMsg { color: rgba(224,224,224,0.8) !important; }
        #modalBtnConfirm, #modalBtnCancel {
            text-transform: uppercase !important;
            letter-spacing: 0.05em !important;
        }
    `,
    doodle: `
        /* === 涂鸦·手绘 · 帖子专属 === */
        /* 纸张纹理背景 */
        body {
            background-image:
                linear-gradient(90deg, rgba(180,140,80,0.05) 1px, transparent 1px),
                linear-gradient(rgba(180,140,80,0.05) 1px, transparent 1px) !important;
            background-size: 20px 20px !important;
        }
        /* ========== 帖子卡片 ========== */
        .post-card {
            border-radius: 255px 15px 225px 15px / 15px 225px 15px 255px !important;
            border: 2.5px dashed #d8cdb8 !important;
            box-shadow: 5px 5px 0 rgba(140,100,50,0.12), 10px 10px 0 rgba(140,100,50,0.05) !important;
        }
        .post-card:hover {
            box-shadow: 3px 3px 0 rgba(140,100,50,0.15), 7px 7px 0 rgba(140,100,50,0.06) !important;
            transform: translate(2px, 2px) !important;
        }
        /* 封面图片在卡片内正常裁剪，不做 wobbly 处理 */
        .post-card [class*="overflow-hidden"] {
            border-radius: inherit !important;
        }
        .post-card [class*="rounded-f"] {
            border-radius: 50% !important;
        }
        /* 帖子内所有文字统一手写字体（按钮保留系统字体，emoji 走 emoji font） */
        .post-card, .post-card * {
            font-family: "ZCOOL KuaiLe", cursive, "Segoe UI Emoji", "Apple Color Emoji", "Noto Color Emoji", sans-serif !important;
        }
        .post-card button, .post-card button * {
            font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif !important;
        }
        .post-card button i, .post-card button [class*="fa"] {
            font-family: FontAwesome !important;
        }
        /* 帖子内所有 Font Awesome 图标保留（编辑/删除链接、相关推荐等） */
        .post-card i, .post-card [class*="fa"] {
            font-family: FontAwesome !important;
        }
        /* 帖子底部元数据（作者、分类、点赞、收藏、浏览、时间）使用系统字体 */
        .post-card .items-center.gap-4.text-xs,
        .post-card .items-center.gap-4.text-xs * {
            font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif !important;
        }
        .post-card .items-center.gap-4.text-xs i,
        .post-card .items-center.gap-4.text-xs [class*="fa"] {
            font-family: FontAwesome !important;
        }
        /* 详情页元数据 */
        .post-card .items-center.gap-5.text-sm,
        .post-card .items-center.gap-5.text-sm * {
            font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif !important;
        }
        .post-card .items-center.gap-5.text-sm i,
        .post-card .items-center.gap-5.text-sm [class*="fa"] {
            font-family: FontAwesome !important;
        }
        /* 帖子元数据分隔线 */
        .post-card .border-b, .post-card .border-t {
            border-style: dashed !important;
            border-color: #d8cdb8 !important;
        }
        /* 帖子标签 */
        .post-card [class*="rounded"]:not([class*="rounded-f"]) {
            border-radius: 12px 4px 12px 4px !important;
        }
        /* AI总结框 */
        .post-card [class*="gradient"] {
            border-style: dashed !important;
            border-color: #d8cdb8 !important;
        }
        /* 帖子之外的手写标题 */
        section h3, h2 {
            font-family: "ZCOOL KuaiLe", cursive !important;
        }
        /* ========== 回复表单 ========== */
        .post-card textarea {
            border-radius: 255px 15px 225px 15px / 15px 225px 15px 255px !important;
            border: 2.5px dashed #d0c5b0 !important;
            background: #fffdf5 !important;
            font-family: "ZCOOL KuaiLe", cursive !important;
        }
        .post-card textarea:focus {
            border-color: #d4a030 !important;
            box-shadow: 0 0 0 3px rgba(180,130,40,0.1) !important;
            outline: none !important;
        }
        /* ========== 回复项之间间距 ========== */
        .post-card.p-5 {
            margin-bottom: 0.75rem !important;
        }
        .post-card.p-5 .border-t {
            border-color: #e8ddd0 !important;
        }
        /* ========== 通用 ========== */
        ::selection { background: rgba(180,130,40,0.25); }
        a:not(.no-underline) {
            color: #8b6914 !important;
            text-decoration: underline wavy rgba(180,130,40,0.25) !important;
            text-underline-offset: 3px !important;
        }
        a:not(.no-underline):hover {
            color: #b8860b !important;
            text-decoration: underline wavy rgba(180,130,40,0.45) !important;
        }
        /* 按钮粗犷手绘 */
        .btn-primary,.btn-publish,.pagination a.active,[class*="bg-blue-500"]:not([class*="rounded-f"]) {
            background: #d4a030 !important;
            border-style: solid !important;
            border-color: #b8891e !important;
            box-shadow: 3px 3px 0 rgba(120,80,40,0.18) !important;
            border-radius: 40px 8px 40px 8px !important;
        }
        [class*="bg-blue-500"]:not([class*="rounded-f"]):hover {
            background: #c89820 !important;
            box-shadow: 2px 2px 0 rgba(120,80,40,0.22) !important;
            transform: translate(1px, 1px) !important;
        }
        /* 分页器 */
        .pagination a {
            border-style: dashed !important;
            border-color: #d0c5b0 !important;
            border-radius: 12px 4px 12px 4px !important;
        }
        .pagination a.active {
            border-style: solid !important;
        }
    `
};

// 构建主题 CSS 字符串
function buildThemeCSS(name) {
    if (name === 'default') return '';
    const colorRules = THEME_COLORS[name] || {};
    const effects = THEME_EFFECTS[name] || '';
    let css = '';
    for (const [sel, color] of Object.entries(colorRules)) {
        if (!color) continue;
        let prop;
        // 对 .bg-black\/40 这类带转义斜杠的处理
        const cleanSel = sel.replace(/\\(.)/g, '$1');
        if (cleanSel.includes('bg-')) prop = 'background';
        else if (cleanSel.includes('text-')) prop = 'color';
        else if (cleanSel.includes('border-')) prop = 'border-color';
        else if (cleanSel.includes('ring-')) prop = '--tw-ring-color';
        else continue;
        css += `${sel}{${prop}:${color}!important}`;
    }
    return css + effects;
}

// 应用主题（先注入新样式再移除旧的，避免白屏）
function applyTheme(name) {
    document.documentElement.setAttribute('data-theme', name);
    localStorage.setItem('bbs-theme', name);

    var css = buildThemeCSS(name);
    var existing = document.getElementById('theme-style-override');
    if (css) {
        var style = document.createElement('style');
        style.id = 'theme-style-override';
        style.textContent = css;
        document.head.appendChild(style);
    }
    // 新样式注入后再移除旧的
    if (existing) existing.remove();

    // 更新切换器按钮高亮
    document.querySelectorAll('.theme-btn').forEach(function(btn) {
        btn.classList.remove('active');
        if (btn.getAttribute('data-theme') === name) {
            btn.classList.add('active');
        }
    });
}

// 循环切换主题
function cycleTheme() {
    var current = document.documentElement.getAttribute('data-theme') || 'default';
    var names = Object.keys(THEME_THEMES);
    var idx = (names.indexOf(current) + 1) % names.length;
    applyTheme(names[idx]);
}

// 初始化主题
function initTheme() {
    var saved = localStorage.getItem('bbs-theme') || 'default';
    applyTheme(saved);
}

// DOMContentLoaded 时自动初始化
document.addEventListener('DOMContentLoaded', initTheme);
