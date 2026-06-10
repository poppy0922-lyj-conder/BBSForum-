package com.bbs;

import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

/**
 * BBS论坛系统 - 唯一启动入口
 * 右键此类 → Run 'Main' 即可启动
 * <p>
 * 部署模式：java -jar BBSForum-exec.jar
 * 默认查找 ./webapp/ 目录作为 JSP 资源目录
 * 也可通过 -Dwebapp.dir=/path/to/webapp 指定
 */
public class Main {

    public static void main(String[] args) throws Exception {
        int port = 80;

        // 1. 优先从系统属性取 webapp 目录
        String webappPath = System.getProperty("webapp.dir");
        File webappDir = null;

        if (webappPath != null && !webappPath.isEmpty()) {
            webappDir = new File(webappPath);
            if (!webappDir.exists()) {
                System.err.println("错误：指定的 webapp.dir 目录不存在: " + webappDir.getAbsolutePath());
                System.exit(1);
            }
        } else {
            // 2. 找当前目录下的 webapp/（生产部署：JAR 同级的 webapp 目录）
            File cwd = new File(System.getProperty("user.dir"));
            File prodWebapp = new File(cwd, "webapp");
            if (prodWebapp.exists()) {
                webappDir = prodWebapp;
            } else {
                // 3. 向上找 src/main/webapp（开发模式）
                File projectRoot = cwd;
                while (projectRoot != null && !new File(projectRoot, "src/main/webapp").exists()) {
                    projectRoot = projectRoot.getParentFile();
                }
                if (projectRoot != null) {
                    webappDir = new File(projectRoot, "src/main/webapp");
                }
            }
        }

        if (webappDir == null || !webappDir.exists()) {
            System.err.println("错误：找不到 webapp 目录！");
            System.err.println("生产部署：将 webapp 目录放在 JAR 同级的 webapp/ 下");
            System.err.println("或通过 -Dwebapp.dir=/path/to/webapp 指定");
            System.err.println("开发模式：在 IDE 中右键 Main.java → Run");
            System.exit(1);
        }

        System.out.println("Web资源目录: " + webappDir.getAbsolutePath());

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.getConnector();

        // 创建 context
        String contextPath = "/BBSForum";
        StandardContext ctx = (StandardContext) tomcat.addWebapp(contextPath, webappDir.getAbsolutePath());
        ctx.setReloadable(false);

        // 尝试添加 target/classes（开发模式），不存在则跳过
        File classesDir = new File(webappDir.getParentFile().getParentFile(), "target/classes");
        WebResourceRoot resources = new StandardRoot(ctx);
        if (classesDir.exists()) {
            resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes", classesDir.getAbsolutePath(), "/"));
        }
        ctx.setResources(resources);

        tomcat.start();

        System.out.println();
        System.out.println("==========================================");
        System.out.println("  BBS技术社区 启动成功！");
        System.out.println("  http://localhost:" + port + contextPath + "/");
        System.out.println("==========================================");

        tomcat.getServer().await();
    }
}
