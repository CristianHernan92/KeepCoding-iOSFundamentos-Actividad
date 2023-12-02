import UIKit

class DetailCell: UITableViewCell {
    @IBOutlet weak var titleOfCell: UILabel!
    @IBOutlet weak var descriptionOfCell: UILabel!
    @IBOutlet weak var imageOfCell: UIImageView!
    @IBOutlet weak var transformationsButton: UIButton!
    @IBAction func transformationsButtonTouchUpInside(_ sender: UIButton) {}
}
