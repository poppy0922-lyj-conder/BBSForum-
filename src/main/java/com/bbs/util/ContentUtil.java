package com.bbs.util;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 内容渲染工具
 * 支持完整 Markdown 语法：标题、代码块、行内代码、图片、链接、加粗、斜体、
 * 引用、无序列表、有序列表、表格、分割线、段落
 */
public class ContentUtil {

    /**
     * 将帖子内容渲染为 HTML
     * 支持：标题、代码块、行内代码、图片、链接、加粗、斜体、引用、列表、表格、分割线、段落
     * HTML 特殊字符会被转义，防止 XSS
     */
    public static String render(String content) {
        if (content == null || content.isEmpty()) {
            return "";
        }

        // 1. 统一换行符为 \n
        content = content.replace("\r\n", "\n").replace("\r", "\n");

        // 2. 先转义 HTML 防止 XSS
        String html = escapeHtml(content);

        // 3. 处理代码块（优先处理，避免内部被其他规则匹配）
        List<String> codeBlockPlaceholders = new ArrayList<>();
        Pattern codeBlockPattern = Pattern.compile("```([\\s\\S]*?)```");
        Matcher codeBlockMatcher = codeBlockPattern.matcher(html);
        StringBuffer sb = new StringBuffer();
        while (codeBlockMatcher.find()) {
            String code = codeBlockMatcher.group(1).trim();
            String placeholder = "%%CODEBLOCK_" + codeBlockPlaceholders.size() + "%%";
            codeBlockPlaceholders.add("<pre class=\"bg-gray-900 text-gray-100 rounded-lg p-4 my-3 text-sm overflow-x-auto\"><code>"
                    + escapeHtml(code) + "</code></pre>");
            codeBlockMatcher.appendReplacement(sb, Matcher.quoteReplacement(placeholder));
        }
        codeBlockMatcher.appendTail(sb);
        html = sb.toString();

        // 4. 行内代码
        html = html.replaceAll("`([^`]+)`", "<code class=\"bg-gray-100 text-red-500 px-1.5 py-0.5 rounded text-xs font-mono\">$1</code>");

        // 5. 图片语法 ![alt](url) → <img>
        html = html.replaceAll("!\\[([^\\]]*)\\]\\(([^)]+)\\)",
                "<img src=\"$2\" alt=\"$1\" class=\"max-w-full rounded-lg my-3\" loading=\"lazy\" onerror=\"this.style.display='none'\">");

        // 6. 链接语法 [text](url) → <a> (但不影响已处理的图片)
        html = html.replaceAll("(?<!!)\\[([^\\]]*)\\]\\(([^)]+)\\)",
                "<a href=\"$2\" target=\"_blank\" class=\"text-blue-500 hover:text-blue-600 underline\">$1</a>");

        // 7. 标题（行首）
        html = html.replaceAll("(?m)^### (.+)$", "<h3 class=\"text-lg font-bold mt-5 mb-2 text-gray-900\">$1</h3>");
        html = html.replaceAll("(?m)^## (.+)$", "<h2 class=\"text-xl font-bold mt-5 mb-2 text-gray-900\">$1</h2>");
        html = html.replaceAll("(?m)^# (.+)$", "<h1 class=\"text-2xl font-bold mt-6 mb-3 text-gray-900\">$1</h1>");

        // 8. 加粗
        html = html.replaceAll("\\*\\*(.+?)\\*\\*", "<strong>$1</strong>");

        // 9. 斜体（不在加粗范围内的单个 *）
        html = html.replaceAll("(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)", "<em>$1</em>");

        // 10. 引用
        html = html.replaceAll("(?m)^> (.+)$", "<blockquote class=\"border-l-4 border-gray-300 pl-4 py-1 my-2 text-gray-600 italic\">$1</blockquote>");

        // 11. 无序列表
        html = html.replaceAll("(?m)^- (.+)$", "<li class=\"text-gray-700 ml-4 list-disc\">$1</li>");

        // 12. 有序列表
        html = html.replaceAll("(?m)^\\d+\\. (.+)$", "<li class=\"text-gray-700 ml-4 list-decimal\">$1</li>");

        // 13. 分割线
        html = html.replaceAll("(?m)^---$", "<hr class=\"my-4 border-gray-200\">");

        // 14. 表格：| header |\n| --- | --- |\n| cell | cell |
        Pattern tablePattern = Pattern.compile(
                "\\|(.+)\\|\\s*\\n\\|[\\s\\-|]+\\|\\s*\\n((?:\\|.+\n*)+)",
                Pattern.MULTILINE
        );
        html = tablePattern.matcher(html).replaceAll(match -> {
            String header = match.group(1);
            String body = match.group(2);

            String[] headerCells = header.split("\\|");
            StringBuilder thHtml = new StringBuilder();
            for (String cell : headerCells) {
                String c = cell.trim();
                if (!c.isEmpty()) {
                    thHtml.append("<th class=\"border border-gray-300 px-3 py-2 bg-gray-50 text-left text-xs font-semibold text-gray-600\">")
                            .append(c).append("</th>");
                }
            }

            StringBuilder bodyHtml = new StringBuilder();
            String[] rows = body.trim().split("\\n");
            for (String row : rows) {
                String[] cells = row.split("\\|");
                bodyHtml.append("<tr>");
                for (String cell : cells) {
                    String c = cell.trim();
                    if (!c.isEmpty()) {
                        bodyHtml.append("<td class=\"border border-gray-300 px-3 py-2 text-sm\">")
                                .append(c).append("</td>");
                    }
                }
                bodyHtml.append("</tr>");
            }

            return "<table class=\"w-full border-collapse my-3\"><thead><tr>" + thHtml + "</tr></thead><tbody>" + bodyHtml + "</tbody></table>";
        });

        // 15. 连续两个换行 → 段落
        html = html.replaceAll("(\r?\n){2,}", "</p><p class=\"mb-3\">");

        // 16. 单个换行 → <br>
        html = html.replaceAll("(\r?\n)", "<br>");

        // 包裹在段落中
        html = "<p class=\"mb-3\">" + html + "</p>";

        // 17. 恢复代码块占位符（在段落包裹之后，避免代码块被 p 标签包裹）
        for (int i = 0; i < codeBlockPlaceholders.size(); i++) {
            html = html.replace("%%CODEBLOCK_" + i + "%%", codeBlockPlaceholders.get(i));
        }

        return html;
    }

    /** 获取内容纯文本摘要（去除Markdown标记和HTML） */
    public static String summary(String content, int maxLen) {
        if (content == null || content.isEmpty()) {
            return "";
        }
        // 统一换行符
        content = content.replace("\r\n", "\n").replace("\r", "\n");

        String text = content;

        // 1. 去掉代码块
        text = text.replaceAll("```[\\s\\S]*?```", "[代码块]");
        // 2. 去掉行内代码
        text = text.replaceAll("`([^`]+)`", "$1");
        // 3. 去掉图片语法
        text = text.replaceAll("!\\[([^\\]]*)\\]\\([^)]+\\)", "[图片]");
        // 4. 去掉链接语法保留文字
        text = text.replaceAll("\\[([^\\]]*)\\]\\([^)]+\\)", "$1");
        // 5. 去掉加粗/斜体标记
        text = text.replaceAll("\\*\\*(.+?)\\*\\*", "$1");
        text = text.replaceAll("(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)", "$1");
        // 6. 去掉行首标题标记（多行模式）
        text = text.replaceAll("(?m)^#+\\s+", "");
        // 7. 去掉行首引用标记
        text = text.replaceAll("(?m)^>\\s*", "");
        // 8. 去掉行首列表标记
        text = text.replaceAll("(?m)^[-*]\\s+", "");
        text = text.replaceAll("(?m)^\\d+\\.\\s+", "");
        // 9. 去掉分割线
        text = text.replaceAll("(?m)^---+$", "");
        // 10. 去掉表格语法（| 开头行）
        text = text.replaceAll("(?m)^\\|.*$", "");
        // 11. 压缩多余空行
        text = text.replaceAll("\n{3,}", "\n\n");
        // 12. 去掉首尾空白
        text = text.trim();

        if (text.length() > maxLen) {
            text = text.substring(0, maxLen) + "...";
        }
        return text;
    }

    private static String escapeHtml(String input) {
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
