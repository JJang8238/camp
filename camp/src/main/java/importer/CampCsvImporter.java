package importer;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;

import dao.CampDAO;
import dto.Camp;
import util.TagUtil;

public class CampCsvImporter {

    public static void main(String[] args) {

        String filePath = "C:/camp_data/camp.csv";

        CampDAO dao = new CampDAO();

        try (
            BufferedReader br = new BufferedReader(
                new InputStreamReader(new FileInputStream(filePath), "MS949")
            )
        ) {
            String line;
            boolean firstLine = true;

            while ((line = br.readLine()) != null) {

                if (firstLine) {
                    firstLine = false;
                    continue;
                }

                String[] row = line.split(",", -1);

                String name = row[1].trim();
                String sido = row[3].trim();
                String sigungu = row[4].trim();
                String address = row[5].trim();

                int normalCamp = TagUtil.parseIntSafe(row[6]);
                int carCamp = TagUtil.parseIntSafe(row[7]);
                int glamping = TagUtil.parseIntSafe(row[8]);
                int caravan = TagUtil.parseIntSafe(row[9]);
                int personalCaravan = TagUtil.parseIntSafe(row[10]);
                int dumpStation = TagUtil.parseIntSafe(row[12]);

                int price = TagUtil.parseIntSafe(row[34]);

                String firePlace = clean(row[23]);
                String facilities = clean(row[24]);
                String nearbyFacilities = clean(row[25]);
                String theme = clean(row[30]);
                String rentals = clean(row[31]);
                String petAllowed = clean(row[32]);

                String tags = TagUtil.makeCampTags(
                    normalCamp,
                    carCamp,
                    glamping,
                    caravan,
                    personalCaravan,
                    dumpStation,
                    firePlace,
                    facilities,
                    nearbyFacilities,
                    theme,
                    rentals,
                    petAllowed
                );

                Camp camp = new Camp();

                camp.setName(name);
                camp.setAddress(address);
                camp.setTags(tags);
                camp.setImage("/assets/img/default.jpg");
                camp.setPrice(price);

                camp.setFacilities(facilities);
                camp.setNearbyFacilities(nearbyFacilities);
                camp.setThemes(theme);

                StringBuilder desc = new StringBuilder();

                desc.append(sido)
                    .append(" ")
                    .append(sigungu)
                    .append("에 위치한 캠핑장입니다.");

                if (!facilities.isEmpty()) {
                    desc.append("\n\n[부대시설]\n")
                        .append(facilities);
                }

                if (!nearbyFacilities.isEmpty()) {
                    desc.append("\n\n[주변 이용 가능 시설]\n")
                        .append(nearbyFacilities);
                }

                if (!theme.isEmpty()) {
                    desc.append("\n\n[테마 환경]\n")
                        .append(theme);
                }

                camp.setDescription(desc.toString());

                if (glamping > 0) {
                    camp.setType("글램핑");
                } else if (caravan > 0) {
                    camp.setType("카라반");
                } else if (carCamp > 0) {
                    camp.setType("오토캠핑");
                } else {
                    camp.setType("일반야영장");
                }

                dao.insertCampFromCsv(camp);
            }

            System.out.println("캠핑장 CSV 등록 완료");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String clean(String value) {
        if (value == null) return "";

        value = value.trim();

        if (value.equalsIgnoreCase("nan")) return "";
        if (value.equals("-")) return "";

        return value;
    }
}