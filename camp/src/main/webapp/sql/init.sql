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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 테스트 계정
INSERT INTO users (username, password, name, email)
VALUES ('test', '1234', '테스트', 'test@test.com');


-- =========================
-- 2. 이메일 인증 테이블
-- =========================
CREATE TABLE email_verification (
    email VARCHAR(100) NOT NULL,
    code CHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    attempts INT DEFAULT 0,
    PRIMARY KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- 3. 캠핑장 테이블
-- =========================
CREATE TABLE camps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    type VARCHAR(50),        -- 예: 글램핑, 카라반, 차박/캠핑
    tags VARCHAR(255),       -- 예: 물놀이,깨끗한
    price INT,
    image VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 캠핑장 더미데이터
INSERT INTO camps (name, address, type, tags, price, image) VALUES
('가평 푸른숲 캠핑장', '경기도 가평군 북면', '글램핑', '물놀이,깨끗한', 150000, 'camp1.jpg'),
('속초 바다 카라반', '강원도 속초시 해안도로', '카라반', '바다,노을', 120000, 'camp2.jpg'),
('양평 별헤는 밤', '경기도 양평군 용문면', '차박/캠핑', '여유있는,별빛', 50000, 'camp3.jpg'),
('제주 숲속 풀빌라', '제주특별자치도 제주시', '풀빌라', '반려견,감성', 350000, 'camp4.jpg');


-- =========================
-- 4. 장소 매칭 테이블
-- =========================
CREATE TABLE matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- 5. 상품 테이블
-- =========================
CREATE TABLE product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    location VARCHAR(100),
    price INT NOT NULL,
    image VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_user
        FOREIGN KEY (seller_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 상품 더미데이터
INSERT INTO product (seller_id, name, description, category, location, price, image) VALUES
(1, '캠핑 텐트', '거의 새상품, 1회 사용했습니다.', '텐트', '안양시', 120000, 'tent.jpg'),
(1, '캠핑 의자', '접이식 의자입니다.', '의자', '수원시', 30000, 'chair.jpg'),
(1, '캠핑 테이블', '사용감 적은 테이블입니다.', '테이블', '성남시', 50000, 'table.jpg'),
(1, '랜턴', '야간 캠핑용 랜턴입니다.', '랜턴', '용인시', 20000, 'lantern.jpg');


-- =========================
-- 6. 상품 이미지 테이블
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 상품 추가 이미지 예시
INSERT INTO product_image (product_id, image_path, sort_order) VALUES
(1, 'tent.jpg', 1),
(2, 'chair.jpg', 1),
(3, 'table.jpg', 1),
(4, 'lantern.jpg', 1);


-- =========================
-- 7. 리뷰 테이블
-- =========================
CREATE TABLE place_review (
    id INT AUTO_INCREMENT PRIMARY KEY,
    place VARCHAR(100),
    content TEXT,
    rating INT,
    userId INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_place_review_user
        FOREIGN KEY (userId) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 8. 캠핑 소식 테이블
-- =========================
CREATE TABLE news (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    summary VARCHAR(300),
    content TEXT NOT NULL,
    category VARCHAR(50),
    image VARCHAR(255),
    views INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO news (title, summary, content, category, image)
VALUES
('봄철 캠핑 준비 체크리스트',
 '초보 캠퍼를 위한 필수 준비물 정리',
 '봄 캠핑을 떠나기 전 반드시 확인해야 할 준비물 리스트를 소개합니다. 텐트, 침낭, 랜턴 등 기본 장비부터 날씨 대비 용품까지 꼼꼼하게 준비하세요.',
 '캠핑 팁',
 'camp1.jpg'),

('전국 벚꽃 캠핑 명소 추천',
 '벚꽃과 함께 즐기는 감성 캠핑',
 '봄 시즌에 맞춰 벚꽃이 아름다운 캠핑장을 추천드립니다. 자연과 함께 힐링할 수 있는 최고의 장소들을 만나보세요.',
 '추천 캠핑장',
 'camp2.jpg'),

('우천 시 캠핑 안전수칙',
 '비 오는 날에도 안전하게 캠핑하는 방법',
 '비가 오는 날에는 미끄럼 사고와 침수 위험이 있습니다. 방수 장비 준비와 안전한 위치 선정이 중요합니다.',
 '안전 정보',
 'camp3.jpg'),

('초보자를 위한 오토캠핑 가이드',
 '처음 캠핑 가는 사람을 위한 완벽 가이드',
 '오토캠핑은 차량을 이용해 편하게 즐길 수 있는 캠핑입니다. 초보자도 쉽게 시작할 수 있는 방법을 안내합니다.',
 '캠핑 팁',
 'camp4.jpg'),

('캠핑 장비 보관 방법',
 '장비 오래 쓰는 관리 꿀팁',
 '캠핑 장비는 사용 후 건조와 청소가 중요합니다. 올바른 보관법으로 장비 수명을 늘려보세요.',
 '캠핑 팁',
 'camp5.jpg');