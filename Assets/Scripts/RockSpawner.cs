using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Collider))]
public class RockSpawner : MonoBehaviour
{
    [SerializeField]
    GameObject rockPrefab;

    [SerializeField]
    [Range(0, 30)]
    int numRocks = 20;

    ArrayList lavaRocks;

    // Start is called before the first frame update
    void Start()
    {
        this.lavaRocks = new ArrayList();
        Bounds b = GetComponent<Collider>().bounds;
        for (int i = 0; i < numRocks; i++) 
        {
            this.lavaRocks.Add(Instantiate(rockPrefab, this.RandPositionInBounds(b), Quaternion.identity));
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private Vector3 RandPositionInBounds(Bounds b)
    {
        return new Vector3(Random.Range(b.center.x - b.extents.x, b.center.x + b.extents.x),
                           Random.Range(b.center.y - b.extents.y, b.center.y + b.extents.y),
                           Random.Range(b.center.z - b.extents.z, b.center.z + b.extents.z));
    }
}
