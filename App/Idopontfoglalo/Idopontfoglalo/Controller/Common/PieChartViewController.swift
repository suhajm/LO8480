//
//  PieChartViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 03. 03..
//

import UIKit
import Charts

class PieChartViewController: ViewController, ChartViewDelegate {
    
    private var ratings: [Rating] = []
    private var pieChart = PieChartView()
    
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var fiveStars: UILabel!
    @IBOutlet weak var fourStars: UILabel!
    @IBOutlet weak var threeStars: UILabel!
    @IBOutlet weak var twoStars: UILabel!
    @IBOutlet weak var oneStar: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avgLabel.text = "\(getAvg())"
        fiveStars.text = "\(getFivePercent())%"
        fourStars.text = "\(getFourPercent())%"
        threeStars.text = "\(getThreePercent())%"
        twoStars.text = "\(getTwoPercent())%"
        oneStar.text = "\(getOnePercent())%"
        pieChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pieChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - (self.view.frame.size.width / 6), height: self.view.frame.size.height - (self.view.frame.height / 6))
        pieChart.center = CGPoint(x:view.frame.size.width / 2, y: (view.frame.size.height / 2) + (view.frame.size.height / 20))
        view.addSubview(pieChart)
        
        let entry5 = PieChartDataEntry(value: getFivePercent(), label: "5 csillag")
        let entry4 = PieChartDataEntry(value: getFourPercent(), label: "4 csillag")
        let entry3 = PieChartDataEntry(value: getThreePercent(), label: "3 csillag")
        let entry2 = PieChartDataEntry(value: getTwoPercent(), label: "2 csillag")
        let entry1 = PieChartDataEntry(value: getOnePercent(), label: "1 csillag")
        
        let set = PieChartDataSet(entries: [entry5, entry4, entry3, entry2, entry1])
        set.drawValuesEnabled = false
        set.colors = ChartColorTemplates.pastel()
        set.label = ""
        let data = PieChartData(dataSet: set)
        pieChart.data = data
    }

    @IBAction func closeBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension PieChartViewController {
    
    func setRatings(ratings: [Rating]) {
        self.ratings = ratings
    }
    
    private func getAvg() -> Double {
        var sum = 0
        for rating in ratings {
            sum = sum + rating.rate!
        }
        
        return round(Double(sum) / Double(ratings.count) * 100) / 100.0
    }
    
    private func getFivePercent() -> Double {
        
        var cnt = 0
        for rating in ratings {
            if rating.rate == 5 {
                cnt = cnt + 1
            }
        }
        
        return round((Double(cnt) / Double(ratings.count)) * 100) / 100.0
        
    }
    
    private func getFourPercent() -> Double {
        
        var cnt = 0
        for rating in ratings {
            if rating.rate == 4 {
                cnt = cnt + 1
            }
        }
        
        return round((Double(cnt) / Double(ratings.count)) * 100) / 100.0
        
    }
    
    private func getThreePercent() -> Double {
        
        var cnt = 0
        for rating in ratings {
            if rating.rate == 3 {
                cnt = cnt + 1
            }
        }
        
        return round((Double(cnt) / Double(ratings.count)) * 100) / 100.0
        
    }
    
    private func getTwoPercent() -> Double {
        
        var cnt = 0
        for rating in ratings {
            if rating.rate == 2 {
                cnt = cnt + 1
            }
        }
        
        return round((Double(cnt) / Double(ratings.count)) * 100) / 100.0
        
    }
    
    private func getOnePercent() -> Double {
        
        var cnt = 0
        for rating in ratings {
            if rating.rate == 1 {
                cnt = cnt + 1
            }
        }
        
        return round((Double(cnt) / Double(ratings.count)) * 100) / 100.0
        
    }
}
