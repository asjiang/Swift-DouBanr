

import UIKit

protocol channelProtocol {
    
    func onChangeChannel(channel_id:String)
    
}

class PinDaoController: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tv: UITableView!
    
    @IBOutlet weak var navbar: UINavigationBar!
    var channelData:NSArray=NSArray()
    var delegae:channelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navbar.backgroundColor=UIColor.blueColor()
        self.navbar.translucent=false
           }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return channelData.count
    
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "pindaocell")
        let rowData:NSDictionary=self.channelData[indexPath.row] as NSDictionary
        
        cell.textLabel.text=rowData["name"] as? String
        
        cell.imageView.image=UIImage(named:"logo4.jpg")
        
        return cell
        
              
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let rowData:NSDictionary=self.channelData[indexPath.row] as NSDictionary
        let channel_id:AnyObject=rowData["channel_id"]! as AnyObject
        let channel:String = "channel=\(channel_id)"
        
        delegae?.onChangeChannel(channel)
        
           // self.dismissViewControllerAnimated(FALSE, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1, 1)
        })
    }

 
  
}

