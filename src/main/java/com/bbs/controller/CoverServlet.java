package com.bbs.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Random;

/**
 * 生成 SVG 封面图片
 * 帖子没有设置封面时，前端用此 Servlet 生成渐变色 + 标题首字符的 SVG 封面
 * URL: /cover/{postId}?title=首字符
 */
@WebServlet("/cover/*")
public class CoverServlet extends HttpServlet {

    /** 10 组渐变色对（十六进制色值，不含 #） */
    private static final String[][] COLOR_PAIRS = {
        {"667eea", "764ba2"}, // 蓝紫
        {"f093fb", "f5576c"}, // 粉红
        {"4facfe", "00f2fe"}, // 青蓝
        {"43e97b", "38f9d7"}, // 青绿
        {"fa709a", "fee140"}, // 粉黄
        {"a18cd1", "fbc2eb"}, // 薰衣草粉
        {"fccb90", "d57eeb"}, // 桃紫
        {"e0c3fc", "8ec5fc"}, // 浅紫蓝
        {"f5576c", "ff6f00"}, // 红橙
        {"667eea", "43e97b"}  // 蓝绿
    };

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少帖子ID");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(pathInfo.substring(1));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "无效的帖子ID");
            return;
        }

        String titleChar = request.getParameter("title");
        if (titleChar == null || titleChar.isEmpty()) {
            titleChar = "?";
        } else {
            titleChar = titleChar.substring(0, 1);
        }

        // 确定性选择渐变色
        String[] colors = COLOR_PAIRS[postId % COLOR_PAIRS.length];
        String color1 = colors[0];
        String color2 = colors[1];

        // 确定性随机生成装饰圆形
        Random rnd = new Random(postId ^ 0xABCDEFL);
        int cx1 = 30 + rnd.nextInt(120);
        int cy1 = 20 + rnd.nextInt(60);
        int r1 = 40 + rnd.nextInt(60);

        int cx2 = 280 + rnd.nextInt(100);
        int cy2 = 140 + rnd.nextInt(80);
        int r2 = 30 + rnd.nextInt(50);

        int cx3 = rnd.nextInt(80);
        int cy3 = 180 + rnd.nextInt(50);
        int r3 = 20 + rnd.nextInt(40);

        String svg = buildSvg(color1, color2, titleChar, cx1, cy1, r1, cx2, cy2, r2, cx3, cy3, r3);

        response.setContentType("image/svg+xml;charset=UTF-8");
        response.setHeader("Cache-Control", "max-age=86400");
        response.getWriter().write(svg);
    }

    private String buildSvg(String c1, String c2, String ch,
                            int cx1, int cy1, int r1,
                            int cx2, int cy2, int r2,
                            int cx3, int cy3, int r3) {
        return "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 416 256\">\n" +
               "  <defs>\n" +
               "    <linearGradient id=\"g\" x1=\"0%\" y1=\"0%\" x2=\"100%\" y2=\"100%\">\n" +
               "      <stop offset=\"0%\" stop-color=\"#" + c1 + "\"/>\n" +
               "      <stop offset=\"100%\" stop-color=\"#" + c2 + "\"/>\n" +
               "    </linearGradient>\n" +
               "  </defs>\n" +
               "  <rect width=\"416\" height=\"256\" fill=\"url(#g)\"/>\n" +
               "  <circle cx=\"" + cx1 + "\" cy=\"" + cy1 + "\" r=\"" + r1 + "\" fill=\"rgba(255,255,255,0.10)\"/>\n" +
               "  <circle cx=\"" + cx2 + "\" cy=\"" + cy2 + "\" r=\"" + r2 + "\" fill=\"rgba(255,255,255,0.08)\"/>\n" +
               "  <circle cx=\"" + cx3 + "\" cy=\"" + cy3 + "\" r=\"" + r3 + "\" fill=\"rgba(255,255,255,0.06)\"/>\n" +
               "  <text x=\"208\" y=\"140\" text-anchor=\"middle\" dominant-baseline=\"central\"\n" +
               "        font-size=\"88\" font-weight=\"bold\" fill=\"white\" font-family=\"Arial, sans-serif\">" +
               escapeXml(ch) + "</text>\n" +
               "</svg>";
    }

    /** 简单 XML 转义，防止注入 */
    private String escapeXml(String s) {
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }
}
