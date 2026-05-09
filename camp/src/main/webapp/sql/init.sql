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
DROP TABLE IF EXISTS inquiries;
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
    profileImage VARCHAR(255),
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    camp_name VARCHAR(100),
    business_name VARCHAR(100),
    business_number VARCHAR(50),
    business_no VARCHAR(50),
    business_img VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO users (username, password, name, email, role, status)
VALUES ('test', '$2a$10$.iRWvuu756Z9g21WKfSKJ.magymk0wH73GkvhA7yF9lrfutIQsMBO', '테스트', 'test@test.com', 'admin', 'ACTIVE');

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
    status VARCHAR(20) DEFAULT 'open',
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO camps (name, address, type, tags, price, image, status) VALUES
('가평 푸른숲 캠핑장', '경기도 가평군 북면', '글램핑', '물놀이,깨끗한', 150000, 'camp1.jpg', 'open'),
('속초 바다 카라반', '강원도 속초시 해안도로', '카라반', '바다,노을', 120000, 'camp2.jpg', 'open'),
('양평 별헤는 밤', '경기도 양평군 용문면', '차박/캠핑', '여유있는,별빛', 50000, 'camp3.jpg', 'open'),
('제주 숲속 풀빌라', '제주특별자치도 제주시', '풀빌라', '반려견,감성', 350000, 'camp4.jpg', 'open');

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
    order_id VARCHAR(100) NULL COMMENT '토스 주문번호',
    payment_key VARCHAR(200) NULL COMMENT '토스 결제키',
    amount INT NULL COMMENT '결제금액',

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
(1, '캠핑 텐트', '거의 새상품, 1회 사용했습니다.', '텐트', '안양시', 120000, 'tent.jpg', 'SELLING'),
(1, '캠핑 의자', '접이식 의자입니다.', '의자', '수원시', 30000, 'chair.jpg', 'SELLING'),
(1, '캠핑 테이블', '사용감 적은 테이블입니다.', '테이블', '성남시', 50000, 'table.jpg', 'SELLING'),
(1, '랜턴', '야간 캠핑용 랜턴입니다.', '랜턴', '용인시', 20000, 'lantern.jpg', 'SELLING');
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

INSERT INTO product_image (product_id, image_path, sort_order) VALUES
(1, 'tent.jpg', 1),
(2, 'chair.jpg', 1),
(3, 'table.jpg', 1),
(4, 'lantern.jpg', 1);

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
    display_order INT DEFAULT 0,
    published_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,

    CONSTRAINT fk_posts_author
        FOREIGN KEY (author_id) REFERENCES users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 9. 이벤트 상세
-- =====================================================
CREATE TABLE event_details (
    post_id INT PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    event_status VARCHAR(20) DEFAULT 'upcoming',
    apply_url VARCHAR(255),
    coupon_code VARCHAR(100),
    max_participants INT NULL,
    winner_announce_at DATETIME NULL,

    CONSTRAINT fk_event_post
        FOREIGN KEY (post_id) REFERENCES posts(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 10. 게시글 이미지
-- =====================================================
CREATE TABLE post_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    image_type VARCHAR(30) DEFAULT 'content',
    sort_order INT DEFAULT 0,

    CONSTRAINT fk_post_image
        FOREIGN KEY (post_id) REFERENCES posts(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 11. 관리자 로그
-- =====================================================
CREATE TABLE admin_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT,
    action VARCHAR(100),
    target_type VARCHAR(50),
    target_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    detail TEXT,

    CONSTRAINT fk_admin_logs_user
        FOREIGN KEY (admin_id) REFERENCES users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 12. 신고
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

-- =====================================================
-- 13. 문의
-- =====================================================
CREATE TABLE inquiries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    username VARCHAR(50),
    title VARCHAR(255),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT '대기'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 14. 캠핑장 중복 지움
-- =====================================================
SELECT name, address, COUNT(*) AS cnt
FROM camps
GROUP BY name, address
HAVING COUNT(*) > 1;

SET autocommit = 1;

DELETE FROM camps
WHERE id NOT IN (
    SELECT min_id
    FROM (
        SELECT MIN(id) AS min_id
        FROM camps
        GROUP BY name, address
    ) x
)
LIMIT 1000;

ALTER TABLE camps
ADD CONSTRAINT uq_camps_name_address UNIQUE (name, address);

-- =====================================================
-- 15.구매 내역 테이블 추가 (init.sql 또는 DB에 직접 실행)
-- =====================================================
CREATE TABLE IF NOT EXISTS product_purchase (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    buyer_id   INT NOT NULL,
    price      INT NOT NULL,
    purchased_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id)   REFERENCES users(id)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 16.찜한 캠핑장 테이블 추가 (DB에 직접 실행)
-- =====================================================
CREATE TABLE IF NOT EXISTS wishlist (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    camp_id    INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_wishlist (user_id, camp_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (camp_id) REFERENCES camps(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

UPDATE camps SET image = '/assets/img/camp1.jpg' WHERE id % 3 = 1;
UPDATE camps SET image = '/assets/img/camp2.jpg' WHERE id % 3 = 2;
UPDATE camps SET image = '/assets/img/camp3.jpg' WHERE id % 3 = 0;
