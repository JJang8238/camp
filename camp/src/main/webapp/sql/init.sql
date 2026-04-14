USE camp_DB;

-- =====================================================
-- 기존 테이블 정리
-- =====================================================

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

-- 필요할 때만 실행 (없으면 에러남)
-- ALTER TABLE place_review DROP FOREIGN KEY fk_place_review_user;

DROP TABLE IF EXISTS users;


-- =====================================================
-- 1. 사용자 (users)
-- =====================================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    profileImage VARCHAR(255),   -- ✅ 유지

    role VARCHAR(20) NOT NULL DEFAULT 'user',      -- user, owner, admin
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- active, pending, rejected

    -- 사장님 정보
    camp_name VARCHAR(100),
    business_name VARCHAR(100),
    business_number VARCHAR(50),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 관리자 계정
INSERT INTO users (username, password, name, email, role, status)
VALUES (
    'test1',
    '$2a$10$HcTps.sThw2NuEG.gPs.2eDrLuJpAzrn8E9VHqlTS5dsEwqZSxbMa',
    '테스트',
    'test1@test.com',
    'admin',
    'active'
);


-- =====================================================
-- 2. 이메일 인증
-- =====================================================
CREATE TABLE email_verification (
    email VARCHAR(100) NOT NULL,
    code CHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    attempts INT DEFAULT 0,
    PRIMARY KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 3. 캠핑장
-- =====================================================
CREATE TABLE camps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    type VARCHAR(50),
    tags VARCHAR(255),
    price INT,
    image VARCHAR(255),
    status VARCHAR(20) DEFAULT 'open'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO camps (name, address, type, tags, price, image, status) VALUES
('가평 푸른숲 캠핑장', '경기도 가평군 북면', '글램핑', '물놀이,깨끗한', 150000, 'camp1.jpg', 'open'),
('속초 바다 카라반', '강원도 속초시 해안도로', '카라반', '바다,노을', 120000, 'camp2.jpg', 'open'),
('양평 별헤는 밤', '경기도 양평군 용문면', '차박/캠핑', '여유있는,별빛', 50000, 'camp3.jpg', 'open'),
('제주 숲속 풀빌라', '제주특별자치도 제주시', '풀빌라', '반려견,감성', 350000, 'camp4.jpg', 'open');

ALTER TABLE camps ADD COLUMN description TEXT;

-- =====================================================
-- 4. 매칭
-- =====================================================
CREATE TABLE matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 5. 예약
-- =====================================================
CREATE TABLE reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    camp_id INT NOT NULL,
    reserve_date DATE NOT NULL,
    people_count INT DEFAULT 1,
    status VARCHAR(30) DEFAULT 'reserved',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (camp_id) REFERENCES camps(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 6. 상품
-- =====================================================
CREATE TABLE product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    location VARCHAR(100),
    price INT NOT NULL,
    image VARCHAR(255),
    status VARCHAR(20) DEFAULT 'selling',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO product (seller_id, name, description, category, location, price, image, status) VALUES
(1, '캠핑 텐트', '거의 새상품', '텐트', '안양시', 120000, 'tent.jpg', 'selling'),
(1, '캠핑 의자', '접이식 의자', '의자', '수원시', 30000, 'chair.jpg', 'selling');


-- =====================================================
-- 7. 상품 이미지
-- =====================================================
CREATE TABLE product_image (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 8. 게시글
-- =====================================================
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_type VARCHAR(30) NOT NULL,
    title VARCHAR(200) NOT NULL,
    summary VARCHAR(500),
    content TEXT NOT NULL,
    category VARCHAR(50),
    thumbnail VARCHAR(255),

    author_id INT,
    view_count INT DEFAULT 0,

    status VARCHAR(20) DEFAULT 'draft',
    is_pinned TINYINT(1) DEFAULT 0,

    published_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 9. 이벤트 상세
-- =====================================================
CREATE TABLE event_details (
    post_id INT PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    event_status VARCHAR(20) DEFAULT 'upcoming',

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 10. 관리자 로그
-- =====================================================
CREATE TABLE admin_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT,
    action VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 11. 신고
-- =====================================================
CREATE TABLE reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_id INT,
    target_type VARCHAR(50),
    target_id INT,
    reason TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reports_user
        FOREIGN KEY (reporter_id) REFERENCES users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


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

ALTER TABLE users ADD COLUMN camp_name VARCHAR(100) NULL;
ALTER TABLE users ADD COLUMN business_name VARCHAR(100) NULL;
ALTER TABLE users ADD COLUMN business_number VARCHAR(50) NULL;

--0414 추가내용 (cs.jsp 문의건)
CREATE TABLE inquiries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    username VARCHAR(50),
    title VARCHAR(255),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT '대기'
);

