module TestStudent;


  typedef struct {
    string name;
    int math_score;
    int physics_score;
    int chemistry_score;
    int biology_score;
    int history_score;
    int geography_score;
    int literature_score;
    int english_score;
  } StudentInfo;

  StudentInfo students[5];

initial begin
    // students[0] = '{("Alice", 92.5, 88.3, 76.8, 94.2, 85.0, 79.5, 90.7, 92.4);
    // students[1] = '{("Bob", 78.4, 91.2, 85.7, 77.9, 88.6, 84.2, 79.8, 80.3);
    // students[2] = '{("Charlie", 89.2, 90.1, 92.7, 88.5, 84.3, 79.7, 86.5, 90.0);
    // students[3] = '{("David", 94.6, 82.7, 76.8, 88.9, 93.2, 87.1, 81.4, 85.8);
    // students[4] = '{("Eve", 81.7, 95.3, 90.4, 83.6, 77.8, 86.5, 92.1, 88.9);


    students[0] = '{"Alice", 92.5, 88.3, 76.8, 94.2, 85.0, 79.5, 90.7, 92.4};
    students[1] = '{"Bob", 78.4, 91.2, 85.7, 77.9, 88.6, 84.2, 79.8, 80.3};
    students[2] = '{"Charlie", 89.2, 90.1, 92.7, 88.5, 84.3, 79.7, 86.5, 90.0};
    students[3] = '{"David", 94.6, 82.7, 76.8, 88.9, 93.2, 87.1, 81.4, 85.8};
    students[4] = '{"Eve", 81.7, 95.3, 90.4, 83.6, 77.8, 86.5, 92.1, 88.9};






    $display("排序后的学生信息：");
    for (int i = 0; i < 5; i++) begin
      $display("学生姓名: %s, 总分: %.2f, 平均分: %.2f", students[i].name, students[i].math_score, students[i].physics_score);
    end

end
endmodule