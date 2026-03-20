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