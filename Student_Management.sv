module StudentInfoSorting;
  typedef enum logic [2:0] {MATH, PHYSICS, CHEMISTRY, BIOLOGY, HISTORY, GEOGRAPHY, LITERATURE, ENGLISH} Subject;
  
  typedef struct {
    string name;
    real math_score;
    real physics_score;
    real chemistry_score;
    real biology_score;
    real history_score;
    real geography_score;
    real literature_score;
    real english_score;
  } StudentInfo;
  
  typedef union {
    real total_score;
    real average_score;
  } ScoreUnion;

  parameter int NUM_STUDENTS = 5;
  StudentInfo students[NUM_STUDENTS];
  
  initial begin
    // 初始化学生成绩信息
    students[0] = '{"Alice", 92.5, 88.3, 76.8, 94.2, 85.0, 79.5, 90.7, 92.4};
    students[1] = '{"Bob", 78.4, 91.2, 85.7, 77.9, 88.6, 84.2, 79.8, 80.3};
    students[2] = '{"Charlie", 89.2, 90.1, 92.7, 88.5, 84.3, 79.7, 86.5, 90.0};
    students[3] = '{"David", 94.6, 82.7, 76.8, 88.9, 93.2, 87.1, 81.4, 85.8};
    students[4] = '{"Eve", 81.7, 95.3, 90.4, 83.6, 77.8, 86.5, 92.1, 88.9};
    
       // 打印排序后的学生信息
    $display("initial students:");
    for (int i = 0; i < NUM_STUDENTS; i++) begin
      $display("Student_name: %s, Sum_score: %.2f, Average_score: %.2f", students[i].name, students[i].math_score, students[i].physics_score);
    end

    // 计算每个学生的总分和平均分
    for (int i = 0; i < NUM_STUDENTS; i++) begin
      ScoreUnion score;
      score.total_score = 0;
      for (int j = 1; j <=  ENGLISH; j++) begin
        case (j)
           MATH: score.total_score += students[i].math_score;
           PHYSICS: score.total_score += students[i].physics_score;
           CHEMISTRY: score.total_score += students[i].chemistry_score;
           BIOLOGY: score.total_score += students[i].biology_score;
           HISTORY: score.total_score += students[i].history_score;
           GEOGRAPHY: score.total_score += students[i].geography_score;
           LITERATURE: score.total_score += students[i].literature_score;
           ENGLISH: score.total_score += students[i].english_score;
        endcase
      end
      
      score.average_score = score.total_score /  int'(ENGLISH);
      students[i].math_score = score.total_score; // 使用math_score字段存储总分
      students[i].physics_score = score.average_score; // 使用physics_score字段存储平均分
    end
    
    // 按总分对学生信息进行排序
    for (int i = 0; i < NUM_STUDENTS - 1; i++) begin
      for (int j = 0; j < NUM_STUDENTS - i - 1; j++) begin
        if (students[j].math_score < students[j + 1].math_score) begin
          StudentInfo temp;
          temp = students[j];
          students[j] = students[j + 1];
          students[j + 1] = temp;
        end
      end
    end
    
    // 打印排序后的学生信息
    $display("\n");
    $display("sorted students:");
    for (int i = 0; i < NUM_STUDENTS; i++) begin
      $display("Student_name: %s, Sum_score: %.2f, Average_score: %.2f", students[i].name, students[i].math_score, students[i].physics_score);
    end
  end
endmodule
