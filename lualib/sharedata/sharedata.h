// ���� ifdef ���Ǵ���ʹ�� DLL �������򵥵�
// ��ı�׼�������� DLL �е������ļ��������������϶���� SHAREDATA_EXPORTS
// ���ű���ġ���ʹ�ô� DLL ��
// �κ�������Ŀ�ϲ�Ӧ����˷��š�������Դ�ļ��а������ļ����κ�������Ŀ���Ὣ
// SHAREDATA_API ������Ϊ�Ǵ� DLL ����ģ����� DLL ���ô˺궨���
// ������Ϊ�Ǳ������ġ�
#ifdef SHAREDATA_EXPORTS
#define SHAREDATA_API __declspec(dllexport)
#else
#define SHAREDATA_API __declspec(dllimport)
#endif

// �����Ǵ� sharedata.dll ������
//class SHAREDATA_API Csharedata {
//public:
//	Csharedata(void);
//	// TODO:  �ڴ�������ķ�����
//};
//
//extern SHAREDATA_API int nsharedata;
//
//SHAREDATA_API int fnsharedata(void);
