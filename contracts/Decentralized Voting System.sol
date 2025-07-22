// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DecentralizedVotingSystem {
    // Structure to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Structure to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    // State variables
    address public owner;
    string public electionTitle;
    bool public votingActive;
    uint256 public totalCandidates;
    uint256 public totalVotes;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event VoterRegistered(address indexed voter);
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoteCasted(address indexed voter, uint256 indexed candidateId);
    event VotingStatusChanged(bool status);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        _;
    }
    
    modifier isRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "Voter is not registered");
        _;
    }
    
    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "Voter has already voted");
        _;
    }
    
    // Constructor
    constructor(string memory _electionTitle) {
        owner = msg.sender;
        electionTitle = _electionTitle;
        votingActive = false;
        totalCandidates = 0;
        totalVotes = 0;
    }
    
    // Core Function 1: Register voters and add candidates
    function registerVoter(address _voterAddress) external onlyOwner {
        require(!voters[_voterAddress].isRegistered, "Voter is already registered");
        
        voters[_voterAddress] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voterAddress);
    }
    
    function addCandidate(string memory _name) external onlyOwner {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        require(!votingActive, "Cannot add candidates while voting is active");
        
        totalCandidates++;
        candidates[totalCandidates] = Candidate({
            id: totalCandidates,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(totalCandidates, _name);
    }
    
    // Core Function 2: Cast vote
    function castVote(uint256 _candidateId) external 
        votingIsActive 
        isRegisteredVoter 
        hasNotVoted 
    {
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Update voter status
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Update candidate vote count
        candidates[_candidateId].voteCount++;
        
        // Update total votes
        totalVotes++;
        
        emit VoteCasted(msg.sender, _candidateId);
    }
    
    // Core Function 3: Get election results and manage voting status
    function getResults() external view returns (
        string[] memory candidateNames,
        uint256[] memory voteCounts,
        uint256 winningCandidateId,
        string memory winnerName
    ) {
        require(totalCandidates > 0, "No candidates found");
        
        candidateNames = new string[](totalCandidates);
        voteCounts = new uint256[](totalCandidates);
        
        uint256 maxVotes = 0;
        uint256 winnerId = 0;
        string memory winner = "";
        
        for (uint256 i = 1; i <= totalCandidates; i++) {
            candidateNames[i - 1] = candidates[i].name;
            voteCounts[i - 1] = candidates[i].voteCount;
            
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
                winner = candidates[i].name;
            }
        }
        
        return (candidateNames, voteCounts, winnerId, winner);
    }

    // 🔹 New Function: Get current winner
    function getWinner() external view returns (
        uint256 winnerId,
        string memory winnerName,
        uint256 winnerVoteCount
    ) {
        require(totalCandidates > 0, "No candidates available");

        uint256 maxVotes = 0;
        uint256 currentWinnerId = 0;

        for (uint256 i = 1; i <= totalCandidates; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                currentWinnerId = i;
            }
        }

        require(currentWinnerId != 0, "No votes cast yet");

        Candidate memory winner = candidates[currentWinnerId];
        return (winner.id, winner.name, winner.voteCount);
    }
    
    function toggleVotingStatus() external onlyOwner {
        votingActive = !votingActive;
        emit VotingStatusChanged(votingActive);
    }
    
    // Additional utility functions
    function getCandidate(uint256 _candidateId) external view returns (
        uint256 id,
        string memory name,
        uint256 voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    function getVoterInfo(address _voterAddress) external view returns (
        bool isRegistered,
        bool hasVoted,
        uint256 votedCandidateId
    ) {
        Voter memory voter = voters[_voterAddress];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
    
    function getElectionStats() external view returns (
        string memory title,
        uint256 candidateCount,
        uint256 voteCount,
        bool status
    ) {
        return (electionTitle, totalCandidates, totalVotes, votingActive);
    }
}
        uint256 candidateCount,
        uint256 voteCount,
        bool status
    ) {
        return (electionTitle, totalCandidates, totalVotes, votingActive);
    }
}
// Added one function suggested by Chatgpt 
