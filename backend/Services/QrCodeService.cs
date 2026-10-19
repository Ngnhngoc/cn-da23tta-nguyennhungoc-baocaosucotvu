using QRCoder;

namespace backend.Services;

public interface IQrCodeService
{
    byte[] GenerateQrCodePng(string qrText, int pixelsPerModule = 10);
    string GenerateQrCodeBase64(string qrText, int pixelsPerModule = 10);
}

public class QrCodeService : IQrCodeService
{
    public byte[] GenerateQrCodePng(string qrText, int pixelsPerModule = 10)
    {
        using var qrGenerator = new QRCodeGenerator();
        using var qrCodeData = qrGenerator.CreateQrCode(qrText, QRCodeGenerator.ECCLevel.Q);
        using var qrCode = new PngByteQRCode(qrCodeData);
        return qrCode.GetGraphic(pixelsPerModule);
    }

    public string GenerateQrCodeBase64(string qrText, int pixelsPerModule = 10)
    {
        var bytes = GenerateQrCodePng(qrText, pixelsPerModule);
        return $"data:image/png;base64,{Convert.ToBase64String(bytes)}";
    }
}
