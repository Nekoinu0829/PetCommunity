# 🐾 Petmate

ペットを愛する人々のためのコミュニティ＆マガジンプラットフォームです。  
日本語UIをベースに制作されたJSP/Servetウェブアプリケーションです。

---

## 📌 プロジェクト概要

| 項目 | 内容 |
|------|------|
| プロジェクト名 | Petmate |
| 開発期間 | 2025 |
| 開発人数 | 1名 |
| 言語 | Java（JSP / Servlet） |
| DB | Oracle XE |
| サーバー | Apache Tomcat |
| IDE | Eclipse |

---

## ✨ 主な機能

### 👤 会員管理
- 会員登録 / ログイン / ログアウト
- マイページ（プロフィール写真・ニックネーム編集）
- 退会
- ニックネーム変更時、投稿・コメントのニックネームを一括同期

### 📝 掲示板（コミュニティ）
- 投稿の作成 / 閲覧 / 編集 / 削除
- 画像アップロード（Base64方式）
- タグによるフィルタリング（犬 / 猫 / すべて）
- ページネーション（15件単位）
- 閲覧数カウント
- いいねトグル（重複防止・トランザクション処理）
- いいねした投稿の一覧表示

### 💬 コメント
- コメントの投稿 / 削除
- 未ログインユーザーはゲスト（ゲスト）として表示

### 📖 マガジン（コンテンツ）
- 管理者が作成する専門コンテンツセクション
- 健康 / しつけ / 食事 / 犬種・猫種図鑑などカテゴリ別分類
- トップページのスライダーに表示

### 🐶 ペット登録
- マイペットの登録 / 編集 / 削除
- ペット名 ＋ プロフィール写真の管理

### 🏠 トップページ
- マガジンスライダー（カテゴリフィルター＋自動スライド）
- 最新コミュニティ投稿のプレビュー
- ヒーローバナー

---

## 🗂 プロジェクト構成

```
Pet/
├── src/main/java/
│   ├── controller/
│   │   ├── UserController.java       # 会員登録・ログイン・ログアウト
│   │   ├── BoardController.java      # 掲示板ページ遷移
│   │   ├── BoardWriteService.java    # 投稿の作成・編集・削除
│   │   ├── LikeController.java       # いいねトグル（JSON API）
│   │   ├── PetController.java        # ペットCRUD（JSON API）
│   │   └── ReplyController.java      # コメントの投稿・削除
│   ├── model/
│   │   ├── BoardDAO.java / BoardDTO.java
│   │   ├── UserDAO.java  / UserDTO.java
│   │   ├── PetDAO.java   / PetDTO.java
│   │   └── ReplyDAO.java / ReplyDTO.java
│   └── util/
│       └── DBManager.java            # Oracle DB接続
├── src/main/webapp/
│   ├── index.jsp                     # トップページ
│   ├── header.jsp / footer.jsp
│   ├── blog/
│   │   ├── community.jsp             # コミュニティ一覧
│   │   ├── detail.jsp                # 投稿詳細
│   │   ├── write.jsp                 # 投稿作成
│   │   ├── update.jsp                # 投稿編集
│   │   ├── contents.jsp              # マガジン一覧
│   │   ├── mypage.jsp                # マイページ
│   │   └── like_list.jsp             # いいね一覧
│   ├── member/
│   │   └── （会員関連JSP）
│   ├── admin/
│   │   └── dashboard.jsp             # 管理者ダッシュボード
│   └── WEB-INF/
│       ├── web.xml
│       └── lib/                      # ojdbc8, jstl, jbcrypt など
```

---

## 🛠 使用技術

| 分類 | 技術 |
|------|------|
| Backend | Java 11+, JSP, Servlet |
| Database | Oracle XE 21c |
| Server | Apache Tomcat 9 |
| Frontend | HTML5, CSS3, JavaScript, jQuery |
| Library | JSTL, ojdbc8, jBCrypt, JSON-java |
| IDE | Eclipse（Eclipse IDE for Enterprise Java Developers 推奨） |

---

## ⚙️ ローカル実行方法

### 事前要件
- JDK 11 以上
- Oracle XE インストール・起動済み（`localhost:1521/xe`）
- Apache Tomcat 9
- Eclipse（Eclipse IDE for Enterprise Java Developers 推奨）

### DB設定

```sql
-- アカウント作成
CREATE USER jsl26 IDENTIFIED BY 1234;
GRANT CONNECT, RESOURCE TO jsl26;

-- テーブル作成
CREATE TABLE MEMBER (
    ID        VARCHAR2(50)  PRIMARY KEY,
    PW        VARCHAR2(200) NOT NULL,
    NICKNAME  VARCHAR2(50),
    PIC       CLOB,
    JOIN_DATE DATE DEFAULT SYSDATE,
    ROLE      NUMBER DEFAULT 0
);

CREATE SEQUENCE BOARD_SEQ START WITH 1 INCREMENT BY 1;
CREATE TABLE BOARD (
    B_NO       NUMBER PRIMARY KEY,
    B_TAG      NVARCHAR2(50),
    B_TITLE    NVARCHAR2(200),
    B_CONTENT  NCLOB,
    B_PIC      CLOB,
    B_WRITER   VARCHAR2(50),
    B_NICKNAME NVARCHAR2(50),
    B_DATE     DATE,
    B_VIEWS    NUMBER DEFAULT 0,
    B_LIKES    NUMBER DEFAULT 0
);

CREATE TABLE BOARD_LIKE (
    ID        VARCHAR2(50),
    B_NO      NUMBER,
    LIKE_DATE DATE DEFAULT SYSDATE,
    PRIMARY KEY (ID, B_NO)
);

CREATE SEQUENCE PET_SEQ START WITH 1 INCREMENT BY 1;
CREATE TABLE PET (
    PET_NO    NUMBER PRIMARY KEY,
    MEMBER_ID VARCHAR2(50),
    PET_NAME  VARCHAR2(100),
    PET_PIC   CLOB,
    REG_DATE  DATE DEFAULT SYSDATE
);

CREATE TABLE REPLY (
    R_NO     NUMBER PRIMARY KEY,
    B_NO     NUMBER,
    R_WRITER VARCHAR2(50),
    CONTENT  VARCHAR2(1000),
    R_DATE   DATE DEFAULT SYSDATE
);
```

### 実行手順

1. Eclipseでプロジェクトをインポート（Existing Projects into Workspace）
2. Tomcatサーバーを追加してプロジェクトをデプロイ
3. `http://localhost:8080/Pet` にアクセス

---

## 📷 スクリーンショット

> 後日追加予定

---

## 📝 その他

- 日本語データ（NVARCHAR2・NCLOB）処理のため、Oracle JDBCプロパティに `oracle.jdbc.defaultNChar=true` を設定
- 画像はBase64エンコードしてDBに直接保存する方式を採用
- いいね機能はトランザクション処理により同時アクセス時の競合を防止
