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

                // 첫 줄은 제목이므로 건너뛰기
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

                String firePlace = row[23];
                String facilities = row[24];
                String nearbyFacilities = row[25];
                String theme = row[30];
                String rentals = row[31];
                String petAllowed = row[32];

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
                camp.setDescription(sido + " " + sigungu + "에 위치한 캠핑장입니다.");

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
}