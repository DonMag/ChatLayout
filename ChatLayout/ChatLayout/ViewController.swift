//
//  ViewController.swift
//  ChatLayout
//
//  Created by Don Mag on 1/7/20.
//  Copyright © 2020 Don Mag. All rights reserved.
//

import UIKit

class ChatBubbleView: UIView {
	
	var sentOrReceived: SOR = .received
	
	override func layoutSubviews() {
		super.layoutSubviews()

		let cRadius = 12.0
		let shp = CAShapeLayer()
		shp.frame = self.bounds
		
		// round appropriate corners and set background color
		// based on this being a "Received" or "Sent" message
		if sentOrReceived == .received {
			shp.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight, .topRight], cornerRadii: CGSize(width: cRadius, height: cRadius)).cgPath
			layer.backgroundColor = UIColor(white: 0.9, alpha: 1.0).cgColor
		} else {
			shp.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: cRadius, height: cRadius)).cgPath
			layer.backgroundColor = UIColor.yellow.cgColor
		}
		
		layer.mask = shp
	}
	
}

class ChatCellBase: UITableViewCell {
	
	@IBOutlet var dateSepLabel: UILabel!
	@IBOutlet var nameTimeLabel: UILabel!
	@IBOutlet var chatLabel: UILabel!
	@IBOutlet var chatBubble: ChatBubbleView!
	
	@IBOutlet var dateShowingConstraint: NSLayoutConstraint!
	@IBOutlet var dateHiddenConstraint: NSLayoutConstraint!

	var sentOrReceived: SOR { return .received }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		chatBubble.sentOrReceived = self.sentOrReceived
	}
	
}

class ReceivedCell: ChatCellBase {
	override var sentOrReceived: SOR { return .received }
}

class SentCell: ChatCellBase {
	override var sentOrReceived: SOR { return .sent }
}

enum SOR {
	case sent
	case received
}

struct ChatObject {
	
	var postedDate: Date = Date()
	var userName: String = ""
	var message: String = ""
	var sentOrReceived: SOR = .sent
	
}

class ChatTableViewController: UITableViewController {
	
	var theData: [ChatObject] = [ChatObject]()
			
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.register(UINib(nibName: "ReceivedCell", bundle: nil), forCellReuseIdentifier: "ReceivedCell")
		tableView.register(UINib(nibName: "SentCell",     bundle: nil), forCellReuseIdentifier: "SentCell"    )

		tableView.separatorStyle = .none
		
		tableView.estimatedRowHeight = 140
		
		getTheData()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return theData.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let d = theData[indexPath.row]
		
		let df = DateFormatter()
		df.timeZone = TimeZone.current
		
		df.dateStyle = .medium
		df.timeStyle = .none
		
		// format the date separator string
		let sepString = "———— " + df.string(from: d.postedDate) + " ————"
		
		df.dateStyle = .none
		df.timeStyle = .short
		
		// format the user name / time string
		let userString = d.userName + ", " + df.string(from: d.postedDate)
		
		var cell: ChatCellBase?
		
		// dequeue a cell with Received or Sent layout
		if d.sentOrReceived == SOR.received {
			cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedCell", for: indexPath) as! ReceivedCell
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "SentCell", for: indexPath) as! SentCell
		}
		
		cell?.dateSepLabel.text = sepString
		cell?.nameTimeLabel.text = userString
		cell?.chatLabel.text = d.message
		
		// show or hide the date separator label
		if indexPath.row == 0 {
			// first message, so show it
			cell?.dateSepLabel.isHidden = false
		} else {
			// check if this message is on a new date
			let prevMessage = theData[indexPath.row - 1]
			if Calendar.current.isDate(d.postedDate, inSameDayAs: prevMessage.postedDate) == true {
				cell?.dateSepLabel.isHidden = true
			} else {
				cell?.dateSepLabel.isHidden = false
			}
		}
		
		// set the constraint priorities based on the date separator label visibility
		cell?.dateShowingConstraint.priority = (cell?.dateSepLabel.isHidden)! ? .defaultLow : .defaultHigh
		cell?.dateHiddenConstraint.priority = (cell?.dateSepLabel.isHidden)! ? .defaultHigh : .defaultLow
		
		// for design / debugging, un-comment this block
		// to set the cell labels background color to green
		// (to makes it easy to see the label frames)
		/*
		[cell?.dateSepLabel, cell?.nameTimeLabel, cell?.chatLabel].forEach {
			$0?.backgroundColor = .green
		}
		*/
		
		return cell!
		
	}
	
}

extension ChatTableViewController {
	
	func getTheData() -> Void {
		
		// generate some sample chat messages data
		// replace this with code to get the data from a server
		
		let oneMinute: Double = 60
		let oneDay: Double = oneMinute * 60 * 24
		
		// example date for first message
		let isoDate = "2020-01-03T10:44:00+0000"
		
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		// local mutable date object
		var d: Date = Date()
		
		if let date = dateFormatter.date(from:isoDate) {
			d = date
		}
		
		// we'll generate 8 sets of example messages, increasing the time-stamps as we go
		for _ in 1...8 {
			theData.append(ChatObject(postedDate: d, userName: "Ricky Bobby",
									  message: "Hello",
									  sentOrReceived: .received))
			
			// add 5 minutes to the date
			d = d.addingTimeInterval(oneMinute * 5.0)
			
			theData.append(ChatObject(postedDate: d, userName: "Ricky Bobby",
									  message: "Are you there?",
									  sentOrReceived: .received))
			
			// add 5 minutes to the date
			d = d.addingTimeInterval(oneMinute * 5.0)
			
			theData.append(ChatObject(postedDate: d, userName: "Cal Naughton Jr",
									  message: "Yes, I'm here.",
									  sentOrReceived: .sent))
			
			// add 12 minutes to the date
			d = d.addingTimeInterval(oneMinute * 12.0)
			
			theData.append(ChatObject(postedDate: d, userName: "Cal Naughton Jr",
									  message: "What do you want?",
									  sentOrReceived: .sent))
			
			//add a day + 20 minutes to the date
			d = d.addingTimeInterval(oneDay + oneMinute * 20.0)
			
			theData.append(ChatObject(postedDate: d, userName: "Ricky Bobby",
									  message: "Just testing the chat layout.",
									  sentOrReceived: .received))
			
			//add a day + 37 minutes to the date
			d = d.addingTimeInterval(oneDay + oneMinute * 37.0)
			
			theData.append(ChatObject(postedDate: d, userName: "Cal Naughton Jr",
									  message: "This message has enough text to cause word-wrap (max Bubble width is 75% of the cell width).",
									  sentOrReceived: .sent))
			
			// add 5 minutes to the date
			d = d.addingTimeInterval(oneMinute * 5.0)
			
			theData.append(ChatObject(postedDate: d, userName: "Ricky Bobby",
									  message: "If we've done this right, everything is working as it should!",
									  sentOrReceived: .received))
			
			//add a day + 20 minutes to the date
			d = d.addingTimeInterval(oneDay + oneMinute * 20.0)
			
		}
		
		// loop through and prepend a count value (since we have 8 sets of the same messages)
		for i in 0..<theData.count {
			theData[i].message = "\(i + 1): \(theData[i].message)"
		}
		
	}
	
}
