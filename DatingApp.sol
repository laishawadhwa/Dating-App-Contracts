pragma solidity ^0.8.0;

contract DatingAPP {
    struct Profile {
        string name;
        uint age;
        string bio;
        string profilePicture;
        uint actionTokens; // Can be in app currency 
    }
    
    struct Match {
        address user1;
        address user2;
        bool isMatched;
    }
    
    mapping(address => Profile) public profiles;
    mapping(address => mapping(address => bool)) public swipes;
    Match[] public matches;
    
    mapping(address => uint) public actionTokensBalance;
    
    event ProfileCreated(address indexed user, string name);
    event Swipe(address indexed user1, address indexed user2, bool isLiked);
    event MatchCreated(address indexed user1, address indexed user2);
    event ActionTokensEarned(address indexed user, uint amount);
    
    modifier requireActionTokens(uint amount) {
        require(profiles[msg.sender].actionTokens >= amount, "Insufficient action tokens.");
        _;
    }
    
    function createProfile(string memory _name, uint _age, string memory _bio, string memory _profilePicture) public {
        require(profiles[msg.sender].age == 0, "Profile already exists.");
        
        profiles[msg.sender] = Profile(_name, _age, _bio, _profilePicture, 0);
        emit ProfileCreated(msg.sender, _name);
    }
    
    function swipe(address _user, bool _isLiked) public requireActionTokens(1) {
        require(profiles[_user].age > 0, "User profile does not exist.");
        require(_user != msg.sender, "You cannot swipe on yourself.");
        
        swipes[msg.sender][_user] = _isLiked;
        profiles[msg.sender].actionTokens--;
        
        if (_isLiked && swipes[_user][msg.sender]) {
            createMatch(msg.sender, _user);
            // Reward users with action tokens for successful matches
            profiles[msg.sender].actionTokens += 2;
            profiles[_user].actionTokens += 2;
        }
        
        emit Swipe(msg.sender, _user, _isLiked);
    }
    
    function createMatch(address _user1, address _user2) private {
        matches.push(Match(_user1, _user2, true));
        emit MatchCreated(_user1, _user2);
    }
    
    function earnActionTokens(uint _amount) public {
        actionTokensBalance[msg.sender] += _amount;
        profiles[msg.sender].actionTokens += _amount;
        
        emit ActionTokensEarned(msg.sender, _amount);
    }
    
    function getMatchCount() public view returns (uint) {
        return matches.length;
    }
}
