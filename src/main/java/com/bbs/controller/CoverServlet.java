package com.bbs.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * 生成 SVG 封面图片
 * 帖子没有设置封面时，前端用此 Servlet 生成渐变色 + 完整标题的 SVG 封面
 * URL: /cover/{postId}?title=完整标题文本
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

        String title = request.getParameter("title");
        if (title == null || title.isEmpty()) {
            title = "?";
        }

        // 截断过长的标题
        if (title.length() > 60) {
            title = title.substring(0, 57) + "...";
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

        String svg = buildSvg(color1, color2, title, cx1, cy1, r1, cx2, cy2, r2, cx3, cy3, r3);

        response.setContentType("image/svg+xml;charset=UTF-8");
        response.setHeader("Cache-Control", "max-age=86400");
        response.getWriter().write(svg);
    }

    /**
     * 将标题按字数自动拆分为多行，并选择合适的字体大小
     * 规则：短标题（≤4字）大号字体，较长标题自动换行并缩小字体
     */
    private String buildSvg(String c1, String c2, String title,
                            int cx1, int cy1, int r1,
                            int cx2, int cy2, int r2,
                            int cx3, int cy3, int r3) {

        // 根据标题长度决定行数和字体大小
        int maxCharsPerLine;
        int fontSize;
        int lineHeight;
        int startY;

        if (title.length() <= 4) {
            // 短标题：大号单行居中
            maxCharsPerLine = title.length();
            fontSize = 72;
            lineHeight = 80;
            startY = 140;
        } else if (title.length() <= 8) {
            // 中等标题：较大字体，1-2行
            maxCharsPerLine = Math.max(4, (int) Math.ceil(title.length() / 2.0));
            fontSize = 48;
            lineHeight = 56;
            startY = 120;
        } else if (title.length() <= 16) {
            // 较长标题：中等字体，2行
            maxCharsPerLine = (int) Math.ceil(title.length() / 2.0);
            fontSize = 34;
            lineHeight = 44;
            startY = 116;
        } else {
            // 长标题：小字体，最多3行
            maxCharsPerLine = (int) Math.ceil(title.length() / 3.0);
            if (maxCharsPerLine < 8) maxCharsPerLine = 8;
            fontSize = 26;
            lineHeight = 36;
            startY = 108;
        }

        // 按最大字符数拆分为行
        List<String> lines = splitLines(title, maxCharsPerLine);

        // 最多显示3行
        if (lines.size() > 3) {
            lines = lines.subList(0, 3);
            String last = lines.get(2);
            if (last.length() > 2) {
                lines.set(2, last.substring(0, last.length() - 2) + "...");
            } else {
                lines.set(2, last + "...");
            }
        }

        // 计算总高度以垂直居中
        int totalHeight = lines.size() * lineHeight;
        int yOffset = startY - totalHeight / 2 + lineHeight / 2;

        StringBuilder textElements = new StringBuilder();
        for (int i = 0; i < lines.size(); i++) {
            int y = yOffset + i * lineHeight;
            textElements.append("  <text x=\"208\" y=\"").append(y)
                        .append("\" text-anchor=\"middle\" dominant-baseline=\"central\"\n")
                        .append("        font-size=\"").append(fontSize)
                        .append("\" font-weight=\"bold\" fill=\"white\"")
                        .append(" font-family=\"Arial, sans-serif\">")
                        .append(escapeXml(lines.get(i)))
                        .append("</text>\n");
        }

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
               textElements.toString() +
               "</svg>";
    }

    /** 按最大字符数拆分文本行（优先在标点/空格处断开，否则按字符数拆分） */
    private List<String> splitLines(String text, int maxChars) {
        List<String> lines = new ArrayList<>();
        int start = 0;
        while (start < text.length()) {
            int end = Math.min(start + maxChars, text.length());
            // 如果不是最后一行，尝试在标点符号后断开
            if (end < text.length()) {
                int breakAt = findBreakPoint(text, start, end);
                if (breakAt > start) {
                    end = breakAt;
                }
            }
            lines.add(text.substring(start, end).trim());
            start = end;
        }
        return lines;
    }

    /** 在指定范围内找到合适的断点（标点、空格后） */
    private int findBreakPoint(String text, int start, int maxEnd) {
        for (int i = maxEnd; i > start; i--) {
            char c = text.charAt(i - 1);
            if (c == ' ' || c == '　' || c == ',' || c == '，' || c == '、'
                || c == '.' || c == '。' || c == '；' || c == ';'
                || c == ')' || c == '）' || c == '》' || c == '」'
                || c == '!' || c == '！' || c == '?' || c == '？'
                || c == ':' || c == '：' || c == '…') {
                return i;
            }
        }
        return -1;
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
