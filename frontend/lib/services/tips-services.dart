import 'dart:math';

class TipsService {
  // List of 50 period-related tips and facts
  static final List<String> _periodTips = [
    "Staying hydrated can help reduce bloating during your period.",
    "Regular exercise can help alleviate menstrual cramps.",
    "Heat therapy, like a warm bath or heating pad, may reduce period pain.",
    "Changes in diet can affect your menstrual cycle and symptoms.",
    "Tracking your period can help predict symptoms and prepare for them.",
    "Menstrual cups can be worn for up to 12 hours, unlike tampons or pads.",
    "PMS symptoms can begin up to two weeks before your period starts.",
    "The average period lasts between 3-7 days.",
    "The average person loses about 2-3 tablespoons of blood during their period.",
    "Menstrual cycles typically range from 21-35 days.",
    "Stress can affect the regularity of your periods.",
    "Certain foods like dark chocolate contain magnesium that may help with cramps.",
    "Period pain is caused by prostaglandins, which cause uterine contractions.",
    "Sleep quality often decreases during menstruation due to hormonal changes.",
    "Vitamin B6 may help reduce PMS symptoms including mood swings.",
    "Iron-rich foods can help prevent anemia during heavy periods.",
    "Herbal teas like ginger and chamomile may help with menstrual discomfort.",
    "Orgasms can sometimes relieve menstrual cramps.",
    "Most people have around 450 periods in their lifetime.",
    "Menstrual synchrony (periods syncing with others) is largely a myth.",
    "Calcium supplements may help reduce PMS symptoms.",
    "Sleeping on your side with legs curled can reduce pressure on the abdomen.",
    "Anti-inflammatory foods may help reduce period pain.",
    "Regular sleep schedules can help regulate your menstrual cycle.",
    "Your body temperature rises slightly after ovulation until your period.",
    "Acupuncture may help with menstrual pain for some people.",
    "Gentle yoga poses can help alleviate period discomfort.",
    "Your voice may change slightly during your menstrual cycle.",
    "A balanced breakfast can help stabilize blood sugar and reduce period fatigue.",
    "Omega-3 fatty acids may help reduce inflammation and period pain.",
    "Avoiding alcohol during your period can reduce inflammation and bloating.",
    "Your skin may be more sensitive during your period, requiring gentler products.",
    "Some medications, including certain antibiotics, can affect the effectiveness of hormonal contraceptives.",
    "Keeping a symptom diary can help identify patterns in your cycle.",
    "Periods may become heavier or lighter during times of significant weight change.",
    "Anxiety and depression can worsen around the time of your period due to hormonal fluctuations.",
    "Endorphins released during exercise act as natural painkillers for cramps.",
    "Menstrual products should be changed regularly to prevent infections.",
    "Deep breathing exercises can help manage period pain and mood swings.",
    "Your sense of smell may be heightened during certain phases of your cycle.",
    "Fertility tracking apps can help predict when your period will start.",
    "Your body may crave iron-rich foods during your period to replace lost iron.",
    "The color and consistency of period blood can vary throughout your cycle.",
    "Cold compresses can help with headaches that sometimes accompany periods.",
    "Period underwear can absorb up to 2 tampons' worth of flow, depending on the brand.",
    "Laughing triggers endorphin release which can help with period discomfort.",
    "Wearing loose clothing during your period can reduce discomfort.",
    "Meditation can help reduce the perception of period pain.",
    "Magnesium supplements may reduce period-related migraines.",
    "The pill was originally developed to treat menstrual disorders, not as contraception.",
  ];

  // Method to get a random tip
  static String getRandomTip() {
    final random = Random();
    return _periodTips[random.nextInt(_periodTips.length)];
  }

  // Method to get a specific tip (for testing or specific requirements)
  static String getTipByIndex(int index) {
    if (index >= 0 && index < _periodTips.length) {
      return _periodTips[index];
    }
    return getRandomTip(); // Fallback to random if index is out of bounds
  }
}
