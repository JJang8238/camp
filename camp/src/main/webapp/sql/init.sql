USE camp_DB;

CREATE TABLE product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price INT,
    image VARCHAR(255)
);

INSERT INTO product (name, price, image) VALUES
('캠핑 텐트', 120000, 'tent.jpg'),
('캠핑 의자', 30000, 'chair.jpg'),
('캠핑 테이블', 50000, 'table.jpg'),
('랜턴', 20000, 'lantern.jpg');

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

# 테스트 아이디
INSERT INTO users (username, password, name, email)
VALUES ('test', '1234', '테스트', 'test@test.com');

CREATE TABLE email_verification (
    email VARCHAR(100) NOT NULL,            -- 인증할 이메일 주소
    code CHAR(6) NOT NULL,                 -- 생성된 인증코드 6자리
    expires_at DATETIME NOT NULL,          -- 만료 시간 (현재 코드상 10분)
    attempts INT DEFAULT 0,                -- 인증 시도 횟수 (보안용)
    PRIMARY KEY (email)                    -- 이메일당 하나의 인증 정보만 유지
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 리뷰 저장 테이블
CREATE TABLE place_review (
    id INT AUTO_INCREMENT PRIMARY KEY,
    place VARCHAR(100),
    content TEXT,
    rating INT,
    userId INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 장소(캠핑장) 정보 테이블 (기존에 없다면 생성)
CREATE TABLE matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(100)
);
-- 캠핑장 정보 등록
CREATE TABLE camps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    type VARCHAR(50),      -- 펜션, 글램핑 등
    tags VARCHAR(255),      -- #물놀이, #깨끗한 등
    price INT,
    image VARCHAR(255)     -- 이미지 파일명 (예: camp1.jpg)
);
--캠핑장 더미데이터
INSERT INTO camps (name, address, type, tags, price, image) 
VALUES 
('가평 푸른숲 캠핑장', '경기도 가평군 북면', '글램핑', '물놀이, 깨끗한', 150000, 'camp1.jpg'),
('속초 바다 카라반', '강원도 속초시 해안도로', '카라반', '바다, 노을', 120000, 'camp2.jpg'),
('양평 별헤는 밤', '경기도 양평군 용문면', '차박/캠핑', '여유있는, 별빛', 50000, 'camp3.jpg'),
('제주 숲속 풀빌라', '제주특별자치도 제주시', '풀빌라', '반려견, 감성', 350000, 'camp1.jpg');