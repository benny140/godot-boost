using Godot;

public partial class Player : RigidBody3D
{
    [Export(PropertyHint.Range, "0.1,5")]
    public float RotationTorque { get; set; } = 1.0f;

    [Export(PropertyHint.Range, "10,50")]
    public float ThrustForce { get; set; } = 25f;

    private bool isLevelComplete = false;
    private bool isCrashed = false;
    private float stabilityTimer = 0.0f;
    private Node landingPad = null;

    private const float StabilityThreshold = 0.5f;
    private const float VelocityThreshold = 0.1f;
    private const float UprightThreshold = 0.9f;

    public override void _Ready()
    {
        BodyEntered += OnBodyEntered;
    }

    public override void _Process(double delta)
    {
        if (isLevelComplete)
        {
            CheckStability((float)delta);
            return;
        }

        if (isCrashed)
            return;

        if (Input.IsActionPressed("rotate_left"))
            ApplyTorque(new Vector3(0, 0, RotationTorque));
        if (Input.IsActionPressed("rotate_right"))
            ApplyTorque(new Vector3(0, 0, -RotationTorque));

        if (Input.IsActionPressed("boost"))
        {
            var forward = Transform.Basis.Y;
            var thrust = new Vector3(forward.X, forward.Y, 0).Normalized() * ThrustForce;
            ApplyCentralForce(thrust);
        }
    }

    private void OnBodyEntered(Node body)
    {
        if (body.IsInGroup("Goal"))
            CompleteLevel(body);
        if (body.IsInGroup("Hazard"))
            CrashSequence();
    }

    private void CrashSequence()
    {
        isCrashed = true;
        var tween = CreateTween();
        tween.TweenInterval(1.0);
        tween.TweenCallback(Callable.From(() => GetTree().ReloadCurrentScene()));
    }

    private void CheckStability(float delta)
    {
        var isUpright = Transform.Basis.Y.Dot(Vector3.Up) > UprightThreshold;
        var isStable =
            LinearVelocity.Length() < VelocityThreshold
            && AngularVelocity.Length() < VelocityThreshold
            && isUpright;

        if (isStable)
        {
            stabilityTimer += delta;
            if (stabilityTimer >= StabilityThreshold)
            {
                if (landingPad is LandingPad pad && !string.IsNullOrEmpty(pad.LevelCompleteScene))
                {
                    GetTree().ChangeSceneToFile(pad.LevelCompleteScene);
                }
                else
                {
                    GetTree().Quit();
                }
            }
        }
        else
        {
            stabilityTimer = 0.0f;
        }
    }

    private void CompleteLevel(Node pad)
    {
        isLevelComplete = true;
        landingPad = pad;
    }
}
