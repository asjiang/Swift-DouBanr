import UIKit
import MediaPlayer
import QuartzCore

class ViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,HttpProtocol, channelProtocol {

    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var pro: UIProgressView!
    @IBOutlet weak var lab: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var btnPlayer: UIImageView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet var tap: UITapGestureRecognizer!
    var eHttp:HttpController = HttpController()
    var tableData:NSArray=NSArray()
    var channelData:NSArray=NSArray()
    var imageCache = Dictionary<String,UIImage>()
    var audioPlayer:MPMoviePlayerController=MPMoviePlayerController();
    var timer:NSTimer?
    
    var indexrow:Int?

    @IBAction func onTap(sender: UITapGestureRecognizer) {
        
        if sender.view == btnPlayer {
                btnPlayer.hidden = true
                audioPlayer.play()
                btnPlayer.removeGestureRecognizer(tap)
                img.addGestureRecognizer(tap)
        } else if sender.view == img {
        
                btnPlayer.hidden=false
                audioPlayer.pause()
                btnPlayer.addGestureRecognizer(tap)
                img.removeGestureRecognizer(tap)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
            eHttp.delegate=self
            eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
            eHttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
        
            pro.progress=0.0
           // img.addGestureRecognizer(tap)
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var channelC:PinDaoController = segue.destinationViewController as PinDaoController
        channelC.delegae=self
        channelC.channelData=self.channelData
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableData.count
       // return 10
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "doubanr")
        let rowData:NSDictionary=self.tableData[indexPath.row] as NSDictionary
        
        cell.textLabel.text=rowData["title"] as? String
        cell.detailTextLabel?.text=rowData["artist"] as? String
       
        cell.imageView.image=UIImage(named:"logo4.jpg")
        
        let url=rowData["picture"] as String
        let imgURL:NSURL=NSURL(string:url)!
        let request:NSURLRequest=NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
            cell.imageView.image=UIImage(data:data) })
        
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.indexrow = indexPath.row
        
        let rowData:NSDictionary=self.tableData[indexPath.row] as NSDictionary
        let url = rowData["url"] as String
        
        //symbol not found
        let audioUrl:String=rowData["url"] as String
        onSetAudio(audioUrl)
        let imgUrl:String=rowData["picture"] as String
        onSetImage(imgUrl)

    
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1, 1)
        })
    }

    func didRecieveResults(results:NSDictionary){
        
           
        if (results["channels"] != nil) {
            self.channelData=results["channels"] as NSArray
        
        }
        
        else if (results["song"] != nil){
            self.tableData=results["song"] as NSArray
            
            indexrow = 0
            let firDict:NSDictionary=self.tableData[0] as NSDictionary
            let audioUrl:String=firDict["url"] as String
            onSetAudio(audioUrl)
            let imgUrl:String=firDict["picture"] as String
            onSetImage(imgUrl)

            
            self.tv.reloadData()
        
        }
        
    }
    func onChangeChannel(channel_id:String)
    {
        eHttp.onSearch("http://douban.fm/j/mine/playlist?\(channel_id)")

    }
    //Audion
    func onSetAudio(url:String){
        
        timer?.invalidate()
        lab.text="00:00"
        
        self.audioPlayer.stop()
        self.audioPlayer.contentURL=NSURL(string:url)
        self.audioPlayer.play()
        
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        
        btnPlayer.removeGestureRecognizer(tap)
        img.addGestureRecognizer(tap)
    }
    func onUpdate()
    {
        let c = audioPlayer.currentPlaybackTime
        
        if c > 0.0
        {
            let t = audioPlayer.duration
            let p:CFloat = CFloat(c/t)
            pro.setProgress(p, animated: true)
            lab.text="\(p)"
            
            let all:Int=Int(c)
            let m:Int=all % 60
            let f:Int=Int(all/60)
            var time:String=""
            if f < 10 {
                time = "0\(f):"
            }else
            {
                time = "\(f):"
            }
            if m < 10 {
                time += "0\(m)"
            }else
            {
                time += "\(m)"
            }
            lab.text=time
            
        
        }

        
        if  audioPlayer.currentPlaybackTime >= audioPlayer.duration && audioPlayer.currentPlaybackTime>0.0
        {
            if indexrow < tableData.count{
                
                let rowData:NSDictionary=self.tableData[indexrow!+1] as NSDictionary
                let url = rowData["url"] as String
                
                //symbol not found
                let audioUrl:String=rowData["url"] as String
                onSetAudio(audioUrl)
                let imgUrl:String=rowData["picture"] as String
                onSetImage(imgUrl)
                
            }
            
        }
        
//    println(c)
//    println(audioPlayer.duration)
//    println(audioPlayer.currentPlaybackTime)
        


    }
    //Image
    func onSetImage(url:String){
        
        let imgURL:NSURL=NSURL(string:url)!
        let request:NSURLRequest=NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
            self.img.image=UIImage(data:data) })
    
    }

}

