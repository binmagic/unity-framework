namespace Sfs2X.Bitswarm
{
    public enum PacketReadState
    {
        //start a brand new packet constructions
        WAIT_NEW_PACKET,
        //waiting for the DATA_SIZE field to come next
        WAIT_DATA_SIZE,
        //handle DATA_SIZE field fragmentation, if it didn't come through all at once
        WAIT_DATA_SIZE_FRAGMENT,
        //handle the DATA field until DATA_SIZE(or more)is reached.
        WAIT_DATA,
        INVALID_DATA,
    }
}





