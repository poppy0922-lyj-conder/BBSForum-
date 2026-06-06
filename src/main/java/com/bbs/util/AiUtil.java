package com.bbs.util;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.*;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Properties;
import java.util.logging.Logger;

/**
 * AI 工具类 - 调用硅基流动 API 生成帖子内容总结
 *
 * 接口：https://docs.siliconflow.cn
 * API Key 等配置从 src/main/resources/config.properties 读取
 */
public class AiUtil {

    private static final Logger LOG = Logger.getLogger(AiUtil.class.getName());

    // 硅基流动 API 配置
    private static final String API_KEY;
    private static final String API_URL;
    private static final String MODEL;

    static {
        Properties config = new Properties();
        try (InputStream is = AiUtil.class.getResourceAsStream("/config.properties")) {
            if (is != null) {
                config.load(is);
            }
        } catch (IOException e) {
            LOG.warning("加载配置文件失败: " + e.getMessage());
        }
        API_KEY = config.getProperty("ai.api.key", "");
        API_URL = config.getProperty("ai.api.url", "https://api.siliconflow.cn/v1/chat/completions");
        MODEL = config.getProperty("ai.model", "Qwen/Qwen2.5-7B-Instruct");
    }

    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    private static final Gson GSON = new Gson();

    /**
     * 同步生成帖子总结（供前端按钮调用）
     * @return 总结文字，失败返回 null
     */
    public static String generateSummary(String title, String content) {
        try {
            return callSiliconFlow(title, content);
        } catch (Exception e) {
            LOG.warning("AI总结生成失败: " + e.getMessage());
            return null;
        }
    }

    /** 调用硅基流动 API */
    private static String callSiliconFlow(String title, String content) throws Exception {
        // 截取内容，避免超出 token 限制
        String text = content.length() > 3000 ? content.substring(0, 3000) + "..." : content;

        JsonObject body = new JsonObject();
        body.addProperty("model", MODEL);
        body.addProperty("max_tokens", 200);
        body.addProperty("temperature", 0.3);

        JsonArray messages = new JsonArray();

        JsonObject systemMsg = new JsonObject();
        systemMsg.addProperty("role", "system");
        systemMsg.addProperty("content", "你是一个技术论坛的内容总结助手。请用1-2句简洁的中文总结帖子的核心内容，不超过80字。只返回总结文字，不要加任何前缀。");
        messages.add(systemMsg);

        JsonObject userMsg = new JsonObject();
        userMsg.addProperty("role", "user");
        userMsg.addProperty("content", "帖子标题：" + title + "\n\n帖子内容：" + text + "\n\n请总结这个帖子：");
        messages.add(userMsg);

        body.add("messages", messages);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(API_URL))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + API_KEY)
                .timeout(Duration.ofSeconds(30))
                .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(body)))
                .build();

        HttpResponse<String> response = HTTP.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            JsonObject resp = GSON.fromJson(response.body(), JsonObject.class);
            return resp.getAsJsonArray("choices")
                    .get(0).getAsJsonObject()
                    .getAsJsonObject("message")
                    .get("content").getAsString().trim();
        } else {
            LOG.warning("API返回错误: " + response.statusCode() + " " + response.body());
            return null;
        }
    }

    /** 将总结存入数据库 */
    private static void saveToDb(int postId, String summary) {
        String sql = "UPDATE posts SET ai_summary = ? WHERE id = ?";
        try (var conn = DBUtil.getConnection();
             var ps = conn.prepareStatement(sql)) {
            ps.setString(1, summary);
            ps.setInt(2, postId);
            ps.executeUpdate();
            LOG.info("AI总结已保存 postId=" + postId);
        } catch (Exception e) {
            LOG.warning("AI总结入库失败: " + e.getMessage());
        }
    }
}
