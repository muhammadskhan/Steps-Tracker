//
//  CalendarViewController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 09/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import JTAppleCalendar
import KDCircularProgress
import DGCharts

protocol CalendarViewControllerDelegate: AnyObject {
    
    func dateDidSelected(date: Date)
}

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var scrollButton: UIButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var freeDates = 0
    weak var delegate: CalendarViewControllerDelegate?
    private var stepsArray = [Steps]()
    private var hourlySteps = [Steps]() {
        didSet {
            self.setChart()
        }
    }
    private lazy var upSellView: UpSellView = {
        let upSellView = Bundle.main.loadNibNamed("UpSellView", owner: self, options: nil)?.first as! UpSellView
        upSellView.source = "Graphs"
        upSellView.translatesAutoresizingMaskIntoConstraints = false
        upSellView.setBlurAlpha(alpha: 0.975)
        return upSellView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.scrollButton.setImage(UIImage(named: "Down"), for: .normal)
        calendarView.minimumInteritemSpacing = 0
        calendarView.minimumLineSpacing = 0
        self.calendarView.isHidden = true
        self.calendarView.scrollToDate(Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.calendarView.isHidden = false
        }
        self.loadHistoryFor(date: Date())
        self.didPurchasedSubscription()
        NotificationCenter.default.addObserver(self, selector: #selector(didPurchasedSubscription), name: Notification.Name.DidPurchasedSubscription, object: nil)
    }
    
    @objc private func didPurchasedSubscription() {
        if !dataManager.isMonthlySubsActive {
            self.chartView.addSubview(self.upSellView)
            self.upSellView.widthAnchor.constraint(equalTo: self.chartView.widthAnchor).isActive = true
            self.upSellView.heightAnchor.constraint(equalTo: self.chartView.heightAnchor).isActive = true
            self.upSellView.delegate = self
            self.upSellView.center = self.chartView.center
        } else {
            self.upSellView.removeFromSuperview()
        }
    }
    
    private func loadHistoryFor(date: Date) {
        hourlySteps = []
        for hour in 0...23 {
            hourlySteps.append(Steps())
            healthKitManager.getStepsForHour(date: date, hour: hour) { (steps) in
                DispatchQueue.main.async {
                    self.hourlySteps[hour] = steps
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
//            self.scrollButton.setImage(UIImage(named: "ArrowUp"), for: .normal)
        }
    }
    
    private func getStepsCountForMonth(date: Date, monthString: String) {
        healthKitManager.getStepsCountForMonth(date: date) { [weak self] (steps) in
            DispatchQueue.main.async {
                if dataManager.isMonthlySubsActive {
                    self?.monthLbl.text = String(format: "%@ (%.0f Steps)", monthString, steps)
                } else {
                    self?.monthLbl.text = monthString
                }
            }
        }
    }
    
    private func getStepsCount(date: Date, dateString: String) {
        healthKitManager.getStepsCountFor(date: date) { [weak self] (steps) in
            DispatchQueue.main.async {
                if dataManager.isMonthlySubsActive {
                    self?.dateLbl.text = dateString + "(\(steps.todaysStepTaken) Steps)"
                } else {
                    self?.dateLbl.text = dateString
                }
            }
        }
    }
    
    private func setChart() {
        
//        self.yAxisTitle.text = "Amplitude"
        chartView.chartDescription.enabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.legend.enabled = false
        chartView.drawBarShadowEnabled = false
        chartView.highlightFullBarEnabled = false
        chartView.rightAxis.enabled = false
//        chartView.drawOrder = [DrawOrder.bar.rawValue,
//                               DrawOrder.line.rawValue]
//        chartView.leftAxis.labelCount = 10
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        
        chartView.xAxis.labelRotationAngle = CGFloat(-45.0)
//        chartView.xAxis.labelWidth = 20
        let l = chartView.legend
        l.wordWrapEnabled = true
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        
        
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.granularity = 1.0
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = 25.0
        xAxis.granularity = 1.0
        xAxis.valueFormatter = AxisValueFormaterXAxis()
        xAxis.drawGridLinesEnabled = false
        self.setChartData(chartData: hourlySteps)
    }
    
    private func setChartData(chartData: [Steps]) {
        
        DispatchQueue.main.async {
            
            let data = self.generateBarData(values: chartData)
            self.chartView.data = data
        }
    }
    
    private func generateBarData(values: [Steps]) -> BarChartData {
        
        var entries: [ChartDataEntry] = Array()

        let xValues = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
        for i in 0 ..< values.count {
            
            //Converting Double To Int and then to double again.
            //So values should display upto one decimal place only
            entries.append(BarChartDataEntry(x: Double(xValues[i]), y: Double(Int(values[i].todaysStepTaken)), icon: nil))
        }
        
        let barDataSet = BarChartDataSet(entries: entries, label: "Bar chart unit test data")
        barDataSet.drawIconsEnabled = false
        barDataSet.colors = [Constants.AppColors.primaryColor]
        barDataSet.valueColors = [UIColor.black]
        let data = BarChartData(dataSet: barDataSet)
        data.barWidth = 0.8
        return data
    }
    
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    
    //MARK:- JTACMonthViewDataSource
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let endDate = Date()
        let calendar = Calendar.current
        let year  = calendar.component(.year, from: endDate)
        let startDate = formatter.date(from: "\(year - 1) 01 01")!
        let generateInDates: InDateCellGeneration = .forAllMonths
        let generateOutDates: OutDateCellGeneration = .tillEndOfGrid
        let numberOfRows = 6
        let firstDayOfWeek: DaysOfWeek = .sunday
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: numberOfRows, calendar: calendar, generateInDates: generateInDates, generateOutDates: generateOutDates, firstDayOfWeek: firstDayOfWeek, hasStrictBoundaries: true)
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    //MARK:- JTACMonthViewDelegate
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        
        let cDate = dateFormatter.string(from: date)
        let todayDate = dateFormatter.string(from: Date())
        
        if cDate == todayDate {
            
            cell.dateLabel.textColor = UIColor.black
        } else {
            
            cell.dateLabel.textColor = Constants.AppColors.textColor
        }
        cell.progressBar.progressColors = [Constants.AppColors.primaryColor, Constants.AppColors.ringGradient2nd]
        healthKitManager.getStepsCountFor(date: date) { (steps) in
            DispatchQueue.main.async {
                self.setupStepsProgressBar(progress: cell.progressBar, steps: steps, animation: false)
            }
        }
        
        cell.contentView.layer.cornerRadius = 4.0
        cell.dateLabel.text = cellState.text
        
        if cellState.dateBelongsTo == .thisMonth {
            
            cell.isHidden = false
        } else {
            
            cell.isHidden = true
        }
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        let cell = cell as! CalendarCell
        cell.dateLabel.text = cellState.text
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        let dateString = "History: \(date.convertIntoStringUsingFormat(format: "MMM d, yyyy") ?? "_")"
        self.getStepsCount(date: date, dateString: dateString)
        self.loadHistoryFor(date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let helper = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let this_date = calendar.visibleDates().monthDates.first(where: { (helper?.component(NSCalendar.Unit.day, from: $0.date))! == 1 })?.date as Any
        let localDate = Date(timeInterval: TimeInterval(Calendar.current.timeZone.secondsFromGMT()), since: this_date as! Date)
        let calendar = Calendar.current
        let month = calendar.component(.month, from: localDate)
        let year = calendar.component(.year, from: localDate)
        let monthName = DateFormatter().monthSymbols[month - 1]
        let dateString = String(format: "%@ %d", monthName, year)
        getStepsCountForMonth(date: localDate, monthString: dateString)
    }
    
    func setupStepsProgressBar(progress: KDCircularProgress,steps: Steps, animation: Bool) {
        
        var realSteps = steps
        realSteps.percentage = Float(Double(realSteps.todaysStepTaken)/Double(realSteps.stepsGoal)) * 100
        let firstValue: Float = Float((270.0 / Double(realSteps.stepsGoal)))
        let angle = firstValue * Float(realSteps.todaysStepTaken)
        if animation {
            if angle < 270 {
                progress.animate(fromAngle: 0, toAngle: Double(angle), duration: 1) { (completed) in
                    
                }
            } else {
                
                progress.animate(fromAngle: 0, toAngle: 270, duration: 1) { (completed) in
                    
                }
            }
        } else {
            
            if angle < 270 {
                
                progress.angle = Double(angle)
            } else {
                
                progress.angle = 270
            }
        }
    }
}

final class AxisValueFormaterXAxis: AxisValueFormatter {
    
    let labels = ["","0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if Int(value) < 0 {
            
            return ""
        }
        let initial = Int(value)
        return labels[initial]
    }
}

extension CalendarViewController: UpSellViewDelegate {
    func currentViewController() -> UIViewController {
        return self
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}

