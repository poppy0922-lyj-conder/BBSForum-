package com.bbs.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

/**
 * 登录/权限拦截器
 * - 保护个人中心：/user/profile 与 /user/profile/*
 * - 保护后台：/admin 与 /admin/*
 */
@WebFilter(urlPatterns = {"/user/profile", "/user/profile/*", "/admin", "/admin/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        HttpSession session = req.getSession(false);
        Object userObj = (session == null) ? null : session.getAttribute("user");
        if (userObj == null) {
            resp.sendRedirect(ctx + "/user/login");
            return;
        }

        // 后台权限：必须为管理员
        if (uri.startsWith(ctx + "/admin")) {
            Map<String, Object> user = (Map<String, Object>) userObj;
            Object role = user.get("role");
            if (!"admin".equals(role)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        chain.doFilter(request, response);
    }
}

