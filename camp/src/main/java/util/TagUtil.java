package util;

import java.util.LinkedHashSet;
import java.util.Set;

public class TagUtil {

    public static String makeCampTags(
            int normalCamp,
            int carCamp,
            int glamping,
            int caravan,
            int personalCaravan,
            int dumpStation,
            String firePlace,
            String facilities,
            String nearbyFacilities,
            String theme,
            String rentals,
            String petAllowed
    ) {
        Set<String> tags = new LinkedHashSet<>();

        // 1. 캠핑장 유형 태그
        if (normalCamp > 0) {
            tags.add("#일반야영장");
        }

        if (carCamp > 0) {
            tags.add("#오토캠핑");
        }

        if (glamping > 0) {
            tags.add("#글램핑");
        }

        if (caravan > 0) {
            tags.add("#카라반");
        }

        if (personalCaravan > 0) {
            tags.add("#개인카라반");
        }

        if (dumpStation > 0) {
            tags.add("#덤프스테이션");
        }

        // 2. 화로대 태그
        if (contains(firePlace, "개별")) {
            tags.add("#개별화로");
        }

        if (contains(firePlace, "공동")) {
            tags.add("#공동화로");
        }

        if (contains(firePlace, "불가")) {
            tags.add("#화로불가");
        }

        // 3. 부대시설 태그
        addTag(tags, facilities, "전기", "#전기");
        addTag(tags, facilities, "무선인터넷", "#와이파이");
        addTag(tags, facilities, "와이파이", "#와이파이");
        addTag(tags, facilities, "장작판매", "#장작판매");
        addTag(tags, facilities, "온수", "#온수");
        addTag(tags, facilities, "물놀이장", "#물놀이장");
        addTag(tags, facilities, "놀이터", "#놀이터");
        addTag(tags, facilities, "산책로", "#산책로");
        addTag(tags, facilities, "운동장", "#운동장");
        addTag(tags, facilities, "운동시설", "#운동시설");
        addTag(tags, facilities, "마트", "#마트편의점");
        addTag(tags, facilities, "편의점", "#마트편의점");
        addTag(tags, facilities, "트렘폴린", "#트램폴린");
        addTag(tags, facilities, "트램폴린", "#트램폴린");

        // 4. 주변시설 태그
        addTag(tags, nearbyFacilities, "계곡", "#계곡");
        addTag(tags, nearbyFacilities, "강", "#강");
        addTag(tags, nearbyFacilities, "호수", "#호수");
        addTag(tags, nearbyFacilities, "바다", "#바다");
        addTag(tags, nearbyFacilities, "해수욕", "#해수욕장");
        addTag(tags, nearbyFacilities, "산", "#산");
        addTag(tags, nearbyFacilities, "숲", "#숲");
        addTag(tags, nearbyFacilities, "낚시", "#낚시");
        addTag(tags, nearbyFacilities, "수영장", "#수영장");
        addTag(tags, nearbyFacilities, "수상레저", "#수상레저");
        addTag(tags, nearbyFacilities, "레일바이크", "#레일바이크");
        addTag(tags, nearbyFacilities, "청소년체험", "#체험활동");
        addTag(tags, nearbyFacilities, "농어촌체험", "#체험활동");

        // 5. 테마환경 태그
        addTag(tags, theme, "봄", "#봄캠핑");
        addTag(tags, theme, "여름", "#여름캠핑");
        addTag(tags, theme, "가을", "#가을캠핑");
        addTag(tags, theme, "겨울", "#겨울캠핑");
        addTag(tags, theme, "일출", "#일출명소");
        addTag(tags, theme, "일몰", "#일몰명소");
        addTag(tags, theme, "별", "#별보기좋은곳");
        addTag(tags, theme, "걷기", "#걷기좋은곳");
        addTag(tags, theme, "자전거", "#자전거");
        addTag(tags, theme, "액티비티", "#액티비티");

        // 6. 장비 대여 태그
        addTag(tags, rentals, "텐트", "#텐트대여");
        addTag(tags, rentals, "릴선", "#릴선대여");
        addTag(tags, rentals, "화로대", "#화로대대여");
        addTag(tags, rentals, "난방기구", "#난방기구대여");
        addTag(tags, rentals, "식기", "#식기대여");
        addTag(tags, rentals, "침낭", "#침낭대여");

        // 7. 반려동물 태그
        if (contains(petAllowed, "가능") && !contains(petAllowed, "불가능")) {
            tags.add("#반려동물동반");
        }

        if (contains(petAllowed, "불가능")) {
            tags.add("#반려동물불가");
        }

        return String.join(" ", tags);
    }

    private static void addTag(Set<String> tags, String text, String keyword, String tag) {
        if (contains(text, keyword)) {
            tags.add(tag);
        }
    }

    private static boolean contains(String text, String keyword) {
        if (text == null) return false;

        String cleanText = text.replace(" ", "").trim();
        String cleanKeyword = keyword.replace(" ", "").trim();

        return cleanText.contains(cleanKeyword);
    }

    public static int parseIntSafe(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return 0;
            }
            return Integer.parseInt(value.trim());
        } catch (Exception e) {
            return 0;
        }
    }
}