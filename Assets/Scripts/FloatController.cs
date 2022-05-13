using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloatController : MonoBehaviour
{
    [SerializeField]
    float buoyancyForce;

    Rigidbody rb;

    // Start is called before the first frame update
    void Start()
    {
        this.rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        float yPos = transform.position.y;
        if(yPos < 0)
        {
            this.rb.AddForce(transform.up * this.buoyancyForce);
        }
    }
}
