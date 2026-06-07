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
