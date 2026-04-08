USE camp_DB;

-- 기존 테이블 정리
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS admin_logs;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS post_images;
DROP TABLE IF EXISTS event_details;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS product_image;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS camps;
DROP TABLE IF EXISTS email_verification;
ALTER TABLE place_review
DROP FOREIGN KEY fk_place_review_user;
DROP TABLE IF EXISTS users;


-- =====================================================
-- 1. 사용자 (users)
-- =====================================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    name          VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    profileImage  VARCHAR(255),
    role          VARCHAR(20) DEFAULT 'USER',     -- USER, ADMIN, BUSINESS
    status        VARCHAR(20) DEFAULT 'ACTIVE',   -- ACTIVE, SUSPENDED, WITHDRAWN
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 테스트 계정
INSERT INTO users (username, password, name, email, role, status)
VALUES ('test', '$2a$10$.iRWvuu756Z9g21WKfSKJ.magymk0wH73GkvhA7yF9lrfutIQsMBO', '테스트', 'test@test.com', 'ADMIN', 'ACTIVE');

-- =====================================================
-- 2. 이메일 인증 (email_verification)
-- =====================================================
CREATE TABLE email_verification (
    email       VARCHAR(100) NOT NULL,
    code        CHAR(6)      NOT NULL,
    expires_at  DATETIME     NOT NULL,
    attempts    INT DEFAULT 0,
    PRIMARY KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 3. 캠핑장 (camps)
-- =====================================================
CREATE TABLE camps (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    type    VARCHAR(50),     -- 글램핑, 카라반 등
    tags    VARCHAR(255),    -- 물놀이, 깨끗한 등
    price   INT,
    image   VARCHAR(255),
    status  VARCHAR(20) DEFAULT 'OPEN'   -- OPEN, HIDDEN, CLOSED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 더미 데이터
INSERT INTO camps (name, address, type, tags, price, image, status) VALUES
('가평 푸른숲 캠핑장', '경기도 가평군 북면', '글램핑', '물놀이,깨끗한', 150000, 'camp1.jpg', 'OPEN'),
('속초 바다 카라반', '강원도 속초시 해안도로', '카라반', '바다,노을', 120000, 'camp2.jpg', 'OPEN'),
('양평 별헤는 밤', '경기도 양평군 용문면', '차박/캠핑', '여유있는,별빛', 50000, 'camp3.jpg', 'OPEN'),
('제주 숲속 풀빌라', '제주특별자치도 제주시', '풀빌라', '반려견,감성', 350000, 'camp4.jpg', 'OPEN');


-- =====================================================
-- 4. 매칭 (matches)
-- =====================================================
CREATE TABLE matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 5. 캠핑 예약 (reservations)
-- =====================================================
CREATE TABLE reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    camp_id INT NOT NULL,
    reserve_date DATE NOT NULL,
    people_count INT DEFAULT 1,
    status VARCHAR(30) DEFAULT 'RESERVED',   -- RESERVED, DONE, CANCELED, REFUNDED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reservation_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reservation_camp
        FOREIGN KEY (camp_id) REFERENCES camps(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 6. 상품 (product)
-- =====================================================
CREATE TABLE product (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    seller_id   INT,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    category    VARCHAR(50),
    location    VARCHAR(100),
    price       INT NOT NULL,
    image       VARCHAR(255),
    status      VARCHAR(20) DEFAULT 'SELLING',  -- SELLING, RESERVED, SOLD, HIDDEN, DELETED
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_user
        FOREIGN KEY (seller_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 더미 데이터
INSERT INTO product (seller_id, name, description, category, location, price, image, status) VALUES
(1, '캠핑 텐트', '거의 새상품, 1회 사용했습니다.', '텐트', '안양시', 120000, 'tent.jpg', 'SELLING'),
(1, '캠핑 의자', '접이식 의자입니다.', '의자', '수원시', 30000, 'chair.jpg', 'SELLING'),
(1, '캠핑 테이블', '사용감 적은 테이블입니다.', '테이블', '성남시', 50000, 'table.jpg', 'SELLING'),
(1, '랜턴', '야간 캠핑용 랜턴입니다.', '랜턴', '용인시', 20000, 'lantern.jpg', 'SELLING');


-- =====================================================
-- 7. 상품 이미지 (product_image)
-- =====================================================
CREATE TABLE product_image (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    product_id  INT NOT NULL,
    image_path  VARCHAR(255) NOT NULL,
    sort_order  INT DEFAULT 1,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_image_product
        FOREIGN KEY (product_id) REFERENCES product(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 예시 데이터
INSERT INTO product_image (product_id, image_path, sort_order) VALUES
(1, 'tent.jpg', 1),
(2, 'chair.jpg', 1),
(3, 'table.jpg', 1),
(4, 'lantern.jpg', 1);


-- =====================================================
-- 8. 게시글 통합 (소식 / 이벤트 / 공지)
-- =====================================================
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_type VARCHAR(30) NOT NULL,             -- news, event, notice
    title VARCHAR(200) NOT NULL,
    summary VARCHAR(500),
    content TEXT NOT NULL,

    category VARCHAR(50),                       -- 캠핑 팁, 안전 정보, 프로모션 등
    thumbnail VARCHAR(255),                     -- 대표 이미지 경로

    author_id INT,                              -- 작성자(관리자 회원 id)
    view_count INT DEFAULT 0,

    status VARCHAR(20) DEFAULT 'draft',         -- draft, published, hidden, deleted
    is_pinned TINYINT(1) DEFAULT 0,             -- 상단 고정 여부
    display_order INT DEFAULT 0,                -- 수동 정렬 우선순위

    published_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,

    CONSTRAINT fk_posts_author
        FOREIGN KEY (author_id) REFERENCES users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 9. 이벤트 상세 (event_details)
-- =====================================================
CREATE TABLE event_details (
    post_id INT PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    event_status VARCHAR(20) DEFAULT 'upcoming',   -- upcoming, ongoing, ended
    apply_url VARCHAR(255),
    coupon_code VARCHAR(100),
    max_participants INT NULL,
    winner_announce_at DATETIME NULL,

    CONSTRAINT fk_event_post
        FOREIGN KEY (post_id) REFERENCES posts(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 10. 게시글 이미지 (post_images)
-- =====================================================
CREATE TABLE post_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    image_type VARCHAR(30) DEFAULT 'content',   -- thumbnail, banner, content
    sort_order INT DEFAULT 0,

    CONSTRAINT fk_post_image
        FOREIGN KEY (post_id) REFERENCES posts(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 11. 관리자 로그 (admin_logs)
-- =====================================================
CREATE TABLE admin_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT,
    action VARCHAR(100),
    target_type VARCHAR(50),
    target_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_admin_logs_user
        FOREIGN KEY (admin_id) REFERENCES users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 12. 신고 시스템 (reports)
-- =====================================================
CREATE TABLE reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_id INT NULL,
    target_type VARCHAR(50),              -- product, review, post 등
    target_id INT,
    reason TEXT,
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, RESOLVED, REJECTED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reports_user
        FOREIGN KEY (reporter_id) REFERENCES users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;





USE camp_DB;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    name          VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    -- 권한: 'USER', 'OWNER', 'ADMIN'
    role          VARCHAR(10)  NOT NULL DEFAULT 'USER', 
    -- 사장님 전용 정보
    business_no   VARCHAR(50),           -- 사업자 번호
    business_img  VARCHAR(255),          -- 사업자 등록증 파일명
    -- 상태: 'PENDING'(대기), 'ACTIVE'(승인), 'REJECTED'(거절)
    status        VARCHAR(20)  DEFAULT 'ACTIVE', 
    profileImage  VARCHAR(255),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 관리자 계정 미리 생성 (데모용)
INSERT INTO users (username, password, name, email, role, status)
VALUES ('admin', '1234', '관리자', 'admin@camp.com', 'ADMIN', 'ACTIVE');