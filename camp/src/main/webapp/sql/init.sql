USE camp_DB;


-- =========================
-- 1. 사용자 테이블
-- =========================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    profileImage VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 테스트 계정
INSERT INTO users (username, password, name, email)
VALUES ('test', '1234', '테스트', 'test@test.com');


-- =========================
-- 2. 상품 테이블
-- =========================
CREATE TABLE product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price INT,
    image VARCHAR(255),
    seller_id INT,
    description TEXT,
    category VARCHAR(50),
    location VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_user
    FOREIGN KEY (seller_id) REFERENCES users(id)
    ON DELETE CASCADE
);

-- 상품 더미 데이터
INSERT INTO product (name, price, image, description)
VALUES
('캠핑 텐트', 120000, 'tent.jpg', '거의 새상품, 1회 사용했습니다.'),
('캠핑 의자', 30000, 'chair.jpg', '편안하고 튼튼합니다.'),
('캠핑 테이블', 50000, 'table.jpg', '접이식 테이블입니다.'),
('랜턴', 20000, 'lantern.jpg', '야외 필수 아이템');


-- =========================
-- 3. 상품 이미지 테이블
-- =========================
CREATE TABLE product_image (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_image_product
    FOREIGN KEY (product_id) REFERENCES product(id)
    ON DELETE CASCADE
);


-- =========================
-- 4. 이메일 인증 테이블
-- =========================
CREATE TABLE email_verification (
    email VARCHAR(100) PRIMARY KEY,
    code CHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    attempts INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- 5. 캠핑장 테이블
-- =========================
CREATE TABLE camps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    type VARCHAR(50),
    tags VARCHAR(255),
    price INT,
    image VARCHAR(255)
);

-- 캠핑장 더미 데이터
INSERT INTO camps (name, address, type, tags, price, image) 
VALUES 
('가평 푸른숲 캠핑장', '경기도 가평군 북면', '글램핑', '물놀이, 깨끗한', 150000, 'camp1.jpg'),
('속초 바다 카라반', '강원도 속초시 해안도로', '카라반', '바다, 노을', 120000, 'camp2.jpg'),
('양평 별헤는 밤', '경기도 양평군 용문면', '차박/캠핑', '여유있는, 별빛', 50000, 'camp3.jpg'),
('제주 숲속 풀빌라', '제주특별자치도 제주시', '풀빌라', '반려견, 감성', 350000, 'camp1.jpg');


-- =========================
-- 6. 리뷰 테이블
-- =========================
CREATE TABLE place_review (
    id INT AUTO_INCREMENT PRIMARY KEY,
    place VARCHAR(100),
    content TEXT,
    rating INT,
    userId INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================
-- 7. 매치 테이블
-- =========================
CREATE TABLE matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(100)
);