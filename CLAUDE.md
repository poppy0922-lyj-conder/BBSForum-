# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

### Prerequisites
- Java 11+ (JDK)
- Maven 3.6+
- MySQL 8.0+ running on localhost:3306

### Database Setup
```bash
# Initialize the database (run against MySQL)
mysql -u root -p < database/init.sql
# Creates database `bbs_forum` and 6 tables (users, categories, posts, replies, demands, score_logs)
```

### Build
```bash
mvn clean package
# Produces: target/BBSForum.war + target/BBSForum-exec.jar
```

### Run
Run the `main()` method in `com.bbs.Main` (embedded Tomcat on port **8088**).
- Context path: `/BBSForum`
- URL: http://localhost:8088/BBSForum/

Or via executable JAR:
```bash
java -jar target/BBSForum-exec.jar
```

### Default Accounts (from init.sql)
| Username | Password | Role |
|----------|----------|------|
| admin    | admin123 | admin |
| test     | test123  | user  |

### Tests
No test directory exists in this project.

## Project Architecture

### Overview
Traditional **Servlet + JSP** MVC (no Spring framework). Direct JDBC with inline SQL in controllers. No service/DAO abstraction layer.

### Technology Stack
| Layer | Technology |
|-------|-----------|
| Backend | Java 11, Jakarta Servlet 5.0, JSTL 2.0 |
| Server | Embedded Apache Tomcat 10.1.52 (via Main.java) |
| Database | MySQL 8.0+, direct JDBC (DriverManager, no connection pool) |
| Auth | Session-based, BCrypt password hashing (jBCrypt 0.4) |
| Frontend | JSP (layout pattern), Tailwind CSS (CDN), Font Awesome 4.7 (CDN) |
| Build | Maven WAR + maven-shade-plugin for executable JAR |

### Package Structure
```
src/main/java/com/bbs/
  Main.java                          -- Embedded Tomcat entry point (port 8088)
  controller/
    HomeServlet.java                 -- GET /index (home page with post list)
    CategoryServlet.java             -- GET /category (posts by category, paginated)
    PostServlet.java                 -- /post/* (create, detail, edit, delete, search, reply)
    UserServlet.java                 -- /user/register, /user/login, /logout
    UserProfileServlet.java          -- /user/profile, /user/profile/edit
    AdminCategoryServlet.java        -- /admin/categories CRUD
  filter/
    AuthFilter.java                  -- Login gate filter (guards /admin, /user/profile, /post/create)
    EncodingFilter.java              -- UTF-8 encoding filter for all requests
  util/
    DBUtil.java                      -- JDBC connection helper (DriverManager)
    PasswordUtil.java                -- BCrypt hash/verify with legacy plaintext compatibility
    ContentUtil.java                 -- HTML content sanitization and summary generation
    PostMapper.java                  -- ResultSet-to-Map mapping utility (post row, category row, related row)
    AiUtil.java                      -- AI-powered content features
```

### JSP Template Pattern (Layout System)
Every page uses a **two-file layout pattern**:
1. **Thin JSP** (e.g., `user/login.jsp`) — sets `pageTitle` and `contentPage` variables
2. **Content JSP** (e.g., `user/login_content.jsp`) — the actual page content
3. **Layout** (`layouts/main.jsp`) — includes the content JSP via `<jsp:include page="${contentPage}" />`

```jsp
<%-- user/login.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="登录" scope="request" />
<c:set var="contentPage" value="/user/login_content.jsp" scope="request" />
<jsp:include page="/layouts/main.jsp" />
```

The layout (`main.jsp`) provides:
- Top navigation bar with user status (logged-in vs anonymous)
- Sidebar with category list (`applicationScope.categoryList`)
- Content area that includes the content JSP
- Footer

### Frontend Assets
- **CSS**: Tailwind CSS via CDN (`cdn.tailwindcss.com`), custom styles in `css/global.css`
- **Icons**: Font Awesome 4.7 via CDN (`bootcdn.net`)
- **JS**: `js/common.js` — lightweight Ajax wrapper (`$.get`, `$.post`), DOM helpers

### URL Routing
Routes are defined via `@WebServlet` annotations on servlet classes (not in `web.xml`):

| Path | Servlet | Methods |
|------|---------|---------|
| `/index` | HomeServlet | GET |
| `/category` | CategoryServlet | GET |
| `/post/*` | PostServlet | GET, POST |
| `/user/login`, `/user/register`, `/logout` | UserServlet | GET, POST |
| `/user/profile`, `/user/profile/edit` | UserProfileServlet | GET, POST |
| `/admin/categories` | AdminCategoryServlet | GET, POST |

### Database (MySQL 8.0+)
- **Database name**: `bbs_forum` (utf8mb4)
- **Tables**: users, categories, posts, replies, demands, score_logs
- **Connection**: `DBUtil` uses `DriverManager.getConnection()` (config: `DB_URL`, `DB_USER`, `DB_PASS`)
- **Data pattern**: Data passed between controllers and JSPs as `Map<String, Object>` (via `PostMapper` utility)

### Authentication & Authorization
- **Session user**: Stored as `sessionScope.user` (a `Map` with keys: id, username, role)
- **AuthFilter**: Guards `/admin/*`, `/user/profile*`, `/post/create` — redirects to `/user/login` if not logged in
- **Admin check**: `sessionScope.user.role == 'admin'` (checked inline in servlets)
- **Password**: BCrypt via jBCrypt; backward-compatible with legacy plaintext passwords (auto-upgraded on login)

### Key Conventions
- Data is passed between servlets and JSPs using `request.setAttribute()` / `request.getAttribute()`
- Session user is a `Map<String, Object>` refreshed from DB on each request (not a POJO)
- Category list is cached in `applicationScope.categoryList` (loaded by HomeServlet on startup)
- SQL queries are written inline in servlet methods (no ORM, no separate DAO files)
- Error handling: 404/500 error pages in `web.xml`, redirect to login page on auth failures
